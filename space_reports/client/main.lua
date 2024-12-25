local QBCore = exports['qb-core']:GetCoreObject()
local nuiOpen = false

RegisterCommand('report', function()
    if not nuiOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openReportForm' })
        nuiOpen = true
    end
end)

RegisterCommand('reports', function()
    TriggerServerEvent('reportSystem:checkStaff') 
end)

RegisterNetEvent('reportSystem:openReports')
AddEventHandler('reportSystem:openReports', function()
    if not nuiOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openReportsList' })
        TriggerServerEvent('reportSystem:getReports')
        nuiOpen = true
    end
end)

RegisterNetEvent('reportSystem:notifyNoPermission')
AddEventHandler('reportSystem:notifyNoPermission', function()
    QBCore.Functions.Notify('No tienes permiso para usar este comando.', 'error')
end)


RegisterNetEvent('reportSystem:receiveReports')
AddEventHandler('reportSystem:receiveReports', function(reports)
    SendNUIMessage({
        action = 'populateReportsList',
        reports = reports
    })
end)


RegisterNUICallback('closeNUI', function()
    SetNuiFocus(false, false)
    nuiOpen = false
end)

RegisterNUICallback('submitReport', function(data)
    TriggerServerEvent('reportSystem:submitReport', data.title, data.content)

    SetNuiFocus(false, false)
    nuiOpen = false
end)

RegisterNUICallback('getReports', function(_, cb)
    TriggerServerEvent('reportSystem:getReports')
    cb('ok')
end)

RegisterNetEvent('reportSystem:showReportDetails')
AddEventHandler('reportSystem:showReportDetails', function(report)
    SendNUIMessage({
        action = 'showReportDetails',
        report = report
    })
end)


RegisterNUICallback('getReportDetails', function(data, cb)
    TriggerServerEvent('reportSystem:getReportDetails', data.id)
    cb('ok')
end)

RegisterNUICallback('deleteReport', function(data, cb)
    local reportId = data.id
    TriggerServerEvent('reportSystem:deleteReport', reportId)
    cb('ok')
end)

RegisterNUICallback('revivePlayer', function(data, cb)
    TriggerServerEvent('reportSystem:revivePlayer', data.id) 
    cb('ok')
end)

RegisterNUICallback('openPedMenu', function(data, cb)
    TriggerServerEvent('reportSystem:openPedMenu', data.id) 
    cb('ok')
end)
