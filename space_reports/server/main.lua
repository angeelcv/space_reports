local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayerDiscordId(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(identifier, 1, 8) == "discord:" then
            local discordId = string.sub(identifier, 9)
            print("Discord ID encontrado para jugador", src, ":", discordId)
            return discordId 
        end
    end
    print("No se encontró Discord ID para jugador", src)
    return nil
end

RegisterServerEvent('reportSystem:submitReport')
AddEventHandler('reportSystem:submitReport', function(title, content)
    local src = source
    local cfxId = GetPlayerIdentifier(src, 0)
    local steamId = GetPlayerIdentifier(src, 1)

    MySQL.insert('INSERT INTO space_reports (title, content, cfxid, steamid, source, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        title,
        content,
        cfxId,
        steamId,
        src,
        'open',
        os.date('%Y-%m-%d %H:%M:%S')
    })

    TriggerClientEvent('QBCore:Notify', src, 'Reporte enviado correctamente.', 'success')

    TriggerEvent('reportSystem:notifyStaff', 'Nuevo reporte recibido: ' .. title)
end)


RegisterServerEvent('reportSystem:notifyStaff')
AddEventHandler('reportSystem:notifyStaff', function(message)
    local notifiedPlayers = {}
    for _, playerId in ipairs(GetPlayers()) do
        local discordId = GetPlayerDiscordId(playerId)
        if discordId and Config.StaffDiscordIDs then
            for _, allowedId in ipairs(Config.StaffDiscordIDs) do
                if discordId == allowedId and not notifiedPlayers[playerId] then
                    print("Notificando a jugador con Discord ID:", discordId, "y Source:", playerId)
                    TriggerClientEvent('QBCore:Notify', playerId, message, 'success')
                    notifiedPlayers[playerId] = true
                end
            end
        end
    end
end)

RegisterServerEvent('reportSystem:getReports')
AddEventHandler('reportSystem:getReports', function()
    local src = source
    MySQL.query('SELECT id, title, content, cfxid, created_at FROM space_reports', {}, function(reports)
        TriggerClientEvent('reportSystem:receiveReports', src, reports)
    end)
end)


RegisterServerEvent('reportSystem:getReportDetails')
AddEventHandler('reportSystem:getReportDetails', function(reportId)
    local src = source
    MySQL.query('SELECT id, title, content, cfxid, source, created_at FROM space_reports WHERE id = ?', {reportId}, function(result)
        if result[1] then
            local report = result[1]
            local playerNameIC = "Desconocido"
            local playerDiscord = "Desconocido"
            local playerSteamName = "Desconocido"
            
            local targetPlayer = QBCore.Functions.GetPlayer(report.source)
            if targetPlayer then
                playerNameIC = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
                playerSteamName = GetPlayerName(report.source)
            end
            
            local discordId = GetPlayerDiscordId(report.source)
            if discordId then
                playerDiscord = discordId
            end

            TriggerClientEvent('reportSystem:showReportDetails', src, {
                id = report.id,
                title = report.title,
                content = report.content,
                cfxid = report.cfxid,
                source = report.source,
                icname = playerNameIC,
                discord = playerDiscord,
                steamname = playerSteamName,
                created_at = report.created_at
            })
        else
            TriggerClientEvent('QBCore:Notify', src, 'No se encontró el reporte.', 'error')
        end
    end)
end)


RegisterServerEvent('reportSystem:deleteReport')
AddEventHandler('reportSystem:deleteReport', function(reportId)
    local src = source
    MySQL.query('DELETE FROM space_reports WHERE id = ?', {reportId}, function()
        TriggerClientEvent('QBCore:Notify', src, 'Reporte eliminado con éxito.', 'success')
        
        MySQL.query('SELECT id, title, content, cfxid, created_at FROM space_reports', {}, function(reports)
            TriggerClientEvent('reportSystem:receiveReports', src, reports)
        end)
    end)
end)

RegisterServerEvent('reportSystem:revivePlayer')
AddEventHandler('reportSystem:revivePlayer', function(reportId)
    local src = source
    MySQL.query('SELECT source FROM space_reports WHERE id = ?', {reportId}, function(result)
        if result[1] and result[1].source then
            local targetId = result[1].source
            TriggerClientEvent('hospital:client:Revive', targetId) 
            TriggerClientEvent('QBCore:Notify', src, 'Jugador revivido con éxito.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'No se encontró al jugador.', 'error')
        end
    end)
end)

RegisterServerEvent('reportSystem:openPedMenu')
AddEventHandler('reportSystem:openPedMenu', function(reportId)
    local src = source
    MySQL.query('SELECT source FROM space_reports WHERE id = ?', {reportId}, function(result)
        if result[1] and result[1].source then
            local targetId = result[1].source
            TriggerClientEvent('qb-clothing:client:openMenu', targetId)
            TriggerClientEvent('QBCore:Notify', src, 'Menú PedMenu abierto para el jugador.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'No se encontró al jugador.', 'error')
        end
    end)
end)


RegisterServerEvent('reportSystem:checkStaff')
AddEventHandler('reportSystem:checkStaff', function()
    local src = source
    local discordId = GetPlayerDiscordId(src)

    local hasPermission = false
    if discordId and Config.StaffDiscordIDs then
        for _, allowedId in ipairs(Config.StaffDiscordIDs) do
            if discordId == allowedId then
                hasPermission = true
                break
            end
        end
    end

    if hasPermission then
        print("El jugador tiene permisos de staff. Abriendo NUI...")
        TriggerClientEvent('reportSystem:openReports', src)
    else
        print("El jugador no tiene permisos de staff.")
        TriggerClientEvent('QBCore:Notify', src, 'No tienes permiso para usar este comando.', 'error')
    end
end)


