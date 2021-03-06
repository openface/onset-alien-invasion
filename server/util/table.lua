Table = {}

function Table.new(conn, name, fields)
    local self = {}
    self.conn = conn
    self.name = name
    self.fields = fields

    self.schema_exists = function()
        local query = mariadb_prepare(self.conn, "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '?' AND table_name = '?'", DBM_DATABASE, self.name)
        mariadb_query(self.conn, query, function()
            if (mariadb_get_value_index_int(1, 1) ~= "1") then
                self.create_schema()
            end
        end)
    end

    --
    -- DROP 
    --
    self.drop_schema = function()
        log.trace("Dropping schema "..self.name)
        local query = mariadb_prepare(self.conn, "DROP TABLE ?", self.name)
        mariadb_query(self.conn, query)
    end

    --
    -- CREATE 
    --    
    self.create_schema = function(force_recreate)
        if force_recreate == true then
            self.drop_schema()
        end

        local create_query = "CREATE TABLE IF NOT EXISTS `" .. self.name .. "` \n("
        create_query = create_query .. "\n`id` int NOT NULL AUTO_INCREMENT,"
        local column_query

        for name,field in pairs(self.fields) do
            column_query = "\n`" .. name .. "` " .. FormatDataType(field.type)

            if field.length ~= nil then
                column_query = column_query .. "(" .. field.length ..")"
            elseif field.type == "char" then
                -- set length if not given for char type
                column_query = column_query .. "(255)"
            elseif field.type == "bool" then
                column_query = column_query .. "(1)"
            end

            if field.null == nil or field.null == false then
                column_query = column_query .. " NOT NULL"
            end

            if field.default ~= nil and field.type ~= "json" then
                column_query = column_query .. " DEFAULT " .. FormatValue(field.default, field)
            end

            if field.unique ~= nil then
                column_query = column_query .. " UNIQUE"
            end

            if field.type == "json" then
                column_query = column_query .. " DEFAULT '[]' COLLATE 'utf8mb4_bin'"
            end

            create_query = create_query .. column_query .. ","
        end

        -- automatic timestamps on create/update (Requires MySQL 5.6)
        create_query = create_query .. "\n`created_at` TIMESTAMP NOT NULL DEFAULT NOW(),"
        create_query = create_query .. "\n`updated_at` TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE NOW(),"
        create_query = create_query .. "\nPRIMARY KEY (`id`)\n)"

        log.trace("Creating schema: " .. create_query)

        local query = mariadb_prepare(self.conn, create_query)
        local result = mariadb_query(self.conn, query)
        return result
    end

    --
    -- INSERT 
    --
    self.insert = function(params, callback)
        local insert_query = "INSERT INTO `" .. self.name .. "` ("

        local column_string
        local formatted_value
        local values_string = ""
        local values = ""
        local counter = 0

        for field,value in pairs(params) do
            if ValidateDataType(value, self.fields[field]) then
                formatted_value = FormatValue(value, self.fields[field])
            else
                log.error("Invalid type for table "..self.name.." in column "..field)
            end

            column_string = "`" .. field .. "`"
            if counter ~= 0 then
                column_string = ", " .. column_string
                formatted_value = ", " .. formatted_value
            end

            values_string = values_string .. formatted_value
            insert_query = insert_query .. column_string

            counter = counter + 1
        end

        insert_query = insert_query .. ") VALUES (" .. values_string .. ")"

        log.trace(insert_query)
        if callback then
            local result = mariadb_query(self.conn, insert_query, callback)
        else
            local result = mariadb_async_query(self.conn, insert_query)
        end
        return result
    end

    --
    -- UPDATE 
    --    
    self.update = function(params, where)
        local update_query = "UPDATE "..self.name.." SET "
        local counter = 0
        local formatted_value

        for column,value in pairs(params) do
            if counter ~= 0 then
                update_query = update_query .. ", "
            end

            if ValidateDataType(value, self.fields[field]) then
                formatted_value = FormatValue(value, self.fields[column])
            else
                log.error("Invalid type for table "..self.name.." in column "..field)
            end

            update_query = update_query .. column ..' = '..formatted_value
            counter = counter + 1
        end

        -- append where clause
        update_query = update_query .. " " .. self._where(where)
        log.trace(update_query)

        local result = mariadb_async_query(self.conn, update_query)
        return result
    end

    self.truncate = function()
        local truncate_query = "TRUNCATE TABLE "..self.name
        log.trace(truncate_query)
        local result = mariadb_async_query(self.conn, truncate_query)
        return result
    end

    -- selects rows
    -- @param fields    "id,name,dob"
    -- @param where     { age = 25 }
    -- @param callback  function
    self.select = function(fields, where, callback)
        local select_query = "SELECT "..fields.." FROM "..self.name

        -- append where clause
        if where then
            select_query = select_query .. " " .. self._where(where)
        end

        log.trace(select_query)
        local query = mariadb_prepare(self.conn, select_query)
        local result = mariadb_query(self.conn, query, callback)
        return true
    end

    -- deletes rows
    -- @param where        
    self.delete = function(where)
        local delete_query = "DELETE FROM "..self.name.." "..self._where(where)
        log.trace(delete_query)
        local query = mariadb_prepare(self.conn, delete_query)
        local result = mariadb_async_query(self.conn, delete_query)
        return result
    end

    -- selects first row only
    -- @param where     { age = 25 }
    self.first = function(where)
        local select_query = "SELECT * FROM "..self.name

        -- append where clause
        select_query = select_query .. " " .. self._where(where) .. " LIMIT 1"
        log.trace(select_query)

        local query = mariadb_prepare(self.conn, select_query)
        local result = mariadb_await_query(self.conn, query)
        return mariadb_get_assoc(1)
    end

    -- builds a where clause
    -- TODO: support more operators
    self._where = function(where)
        local where_clause = "WHERE ("
        local counter = 0
        local condition = ""
        local equation
        local field_type

        for column,value in pairs(where) do
            field_type = self.fields[column].type

            if field_type ~= "number" and field_type ~= "bool" then
                value = "'"..value.."'"
            end

            equation = column .. ' = ' .. value

            if counter ~= 0 then
                equation = " AND "..equation
            end

            condition = condition .. equation
            counter = counter + 1
        end
        where_clause = where_clause .. condition .. ")"
        return where_clause
    end
    return self
end
