local QBCore = exports['qb-core']:GetCoreObject()
local businesses = {}
local ownedStocks = {}
local reduce = 0
local increase = 0

CreateThread(function()
    math.randomseed(os.time())
end)

local function ReduceStock(jobname)
    local stock = MySQL.query.await('SELECT * FROM stock_funds WHERE job_name = @job_name', {['@job_name'] = jobname  })
    local increase = math.random(Config.Values['moveamount'] - math.floor((Config.Values['moveamount'] * 0.25) * 1),Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1))
    local updateamount = tonumber(table.unpack(stock).amount) - increase
    local random = math.random(1,100)
    if updateamount < 0 then
        updateamount = updateamount * -1
        random = 65
    end
    random = random + reduce
    MySQL.query("UPDATE `stock_funds` SET `amount` = '"..updateamount.."' WHERE job_name = @job_name", { ['@job_name'] = jobname })
    if random < 60 then 
        reduce = reduce + 2
        ReduceStock(jobname)
    else
        RegisterServerEvent('k-stocks:increasestock', jobname)
        local reduce = 0
    end
end

local function IncreaseStock(jobname)
    local stock = MySQL.query.await('SELECT * FROM stock_funds WHERE job_name = @job_name', {['@job_name'] = jobname  })
    local increase = math.random(Config.Values['moveamount'] - math.floor((Config.Values['moveamount'] * 0.25) * 1),Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1))
    local updateamount = tonumber(table.unpack(stock).amount) + increase
    local random = math.random(1,100)
    random = random + increase
    MySQL.query("UPDATE `stock_funds` SET `amount` = "..updateamount.." WHERE job_name = @job_name", { ['@job_name'] = jobname })	 
    if math.random(1,100) < 60 then 
        increase = increase + 2
        IncreaseStock(jobname)
    else
        ReduceStock(jobname)
        local increase = 0
    end
end

CreateThread(function()
    while true do
        local businesses = MySQL.query.await('SELECT * FROM management_funds WHERE `type`', {'boss'})
        for i = 1,#businesses,1 do
            local restricted = false
            local stock = nil
            local stock = MySQL.query.await('SELECT * FROM stock_funds WHERE job_name = @job_name', {['@job_name'] = tostring(businesses[i].job_name)})
            local jobcount = Config.Target['restrictedjobs']
            for u = 1,#jobcount,1 do
                if businesses[i].job_name == jobcount[u] then
                    restricted = true
                end
            end
            Wait(0)
            if not restricted then
                if table.unpack(stock) == nil then
                    if businesses[i].type == 'boss' then
                    --if tostring(Config.Restriced1) ~= tostring(businesses[i].job_name) and tostring(Config.Restriced2) ~= tostring(businesses[i].job_name) then
                        MySQL.Async.insert('INSERT INTO stock_funds (`id`, `job_name`, `amount`) VALUES (?, ?, ?)', {math.random(22222,999999), businesses[i].job_name, (businesses[i].amount * Config.Values['goal'])})
                        stock = MySQL.query.await('SELECT * FROM stock_funds WHERE job_name = @job_name', {['@job_name'] = businesses[i].job_name})
                    end
                end
                Wait(0)
                if businesses[i].type == 'boss' then
                    if table.unpack(stock) ~= nil then
                        if (Config.Values['goal'] * tonumber(businesses[i].amount)) < tonumber(table.unpack(stock).amount) then
                            ReduceStock(businesses[i].job_name)
                            if ((Config.Values['goal'] * 2) * tonumber(businesses[i].amount)) < tonumber(table.unpack(stock).amount) then
                                ReduceStock(businesses[i].job_name)
                                if ((Config.Values['goal'] * 3) * tonumber(businesses[i].amount)) < tonumber(table.unpack(stock).amount) then
                                    ReduceStock(businesses[i].job_name)
                                end
                            end
                        elseif (Config.Values['goal'] * tonumber(businesses[i].amount)) > tonumber(table.unpack(stock).amount) then
                            IncreaseStock(businesses[i].job_name)
                            if ((Config.Values['goal'] * 2) * tonumber(businesses[i].amount)) > tonumber(table.unpack(stock).amount) then
                                IncreaseStock(businesses[i].job_name)
                                if ((Config.Values['goal'] * 3) * tonumber(businesses[i].amount)) > tonumber(table.unpack(stock).amount) then
                                    IncreaseStock(businesses[i].job_name)
                                end
                            end
                        end
                    end 
                end  
            end        
        end
        Wait(Config.Values['refresh'] * 60000)
    end
end)

RegisterServerEvent('k-stocks:reducestock', function(jobname)
    ReduceStock(jobname)
end)

RegisterServerEvent('k-stocks:increasestock', function(jobname)
    IncreaseStock(jobname)
end)

RegisterServerEvent('k-stocks:Transfer', function(ply2, amount, job, stocksply)
    local citizenid = QBCore.Functions.GetPlayer(stocksply).PlayerData.citizenid
    local citizenid2 = QBCore.Functions.GetPlayer(ply2).PlayerData.citizenid
    local owned = MySQL.query.await('SELECT * FROM stocks WHERE citizenid = @cid AND type = @job_name', {['@cid'] = citizenid, ['@job_name'] = job})
    local owned2 = MySQL.query.await('SELECT * FROM stocks WHERE citizenid = @cid AND type = @job_name', {['@cid'] = citizenid2, ['@job_name'] = job})
    if tonumber(table.unpack(owned).amount) >= amount then
        if not next(owned2) then
            local plynewamount = tonumber(table.unpack(owned).amount) - amount
            MySQL.query("UPDATE `stocks` SET `amount` = "..plynewamount.." WHERE citizenid = @type AND type = @fix", { ['@type'] = citizenid, ['@fix'] = job})
            MySQL.Async.insert('INSERT INTO stocks (`id`, `citizenid`, `type`, `amount`) VALUES (?, ?, ?, ?)', {math.random(22222,999999), citizenid2, job, amount})
            TriggerClientEvent('QBCore:Notify', source, 'Shares Transferred.', 'success', 5000)
            if source ~= stocksply then
                TriggerClientEvent('QBCore:Notify', stocksply, 'Shares Transferred.', 'success', 5000)
            end
            TriggerClientEvent('QBCore:Notify', ply2, 'Shares Transferred.', 'success', 5000)
        else
            local plynewamount = tonumber(table.unpack(owned).amount) - amount
            local ply2newamount = tonumber(table.unpack(owned2).amount) + amount
            MySQL.query("UPDATE `stocks` SET `amount` = "..plynewamount.." WHERE citizenid = @type AND type = @fix", { ['@type'] = citizenid, ['@fix'] = job})
            MySQL.query("UPDATE `stocks` SET `amount` = "..ply2newamount.." WHERE citizenid = @type2 AND type = @fix2", { ['@type2'] = citizenid2, ['@fix2'] = job})
            TriggerClientEvent('QBCore:Notify', source, 'Shares Transferred.', 'success', 5000)
            if source ~= stocksply then
                TriggerClientEvent('QBCore:Notify', stocksply, 'Shares Transferred.', 'success', 5000)
            end
            TriggerClientEvent('QBCore:Notify', ply2, 'Shares Transferred.', 'success', 5000)
        end
    end
end)

RegisterServerEvent('k-stocks:BuySell', function(amount, job, type, worth, stocksply)
    local src = source
    local Player = QBCore.Functions.GetPlayer(stocksply)
    local citizenid = QBCore.Functions.GetPlayer(stocksply).PlayerData.citizenid
    local owned = MySQL.query.await('SELECT * FROM stocks WHERE citizenid = @cid AND type = @job_name', {['@cid'] = citizenid, ['@job_name'] = job})
    if type == 'Sell' then
        if tonumber(table.unpack(owned).amount) >= amount then
            plynewamount = tonumber(table.unpack(owned).amount) - amount
            if exports['qb-management']:RemoveMoney(job, (amount * tonumber(worth))) then            
                MySQL.query("UPDATE `stocks` SET `amount` = "..plynewamount.." WHERE citizenid = @cid AND type = @job_name", {['@cid'] = citizenid, ['@job_name'] = job})
                Player.Functions.AddMoney('bank', (amount * worth))            
                TriggerClientEvent('QBCore:Notify', src, 'Shares Transferred.', 'success', 5000)
                if src ~= stocksply then
                    TriggerClientEvent('QBCore:Notify', stocksply, 'Shares Transferred.', 'success', 5000)
                end
                Wait(Config.Values['refresh'] * 60000)
                ReduceStock(job)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Sales Unavailable for this business.', 'error', 5000)
                if src ~= stocksply then
                    TriggerClientEvent('QBCore:Notify', stocksply, 'Sales Unavailable for this business.', 'error', 5000)
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'You don\'t have enough Shares.', 'error', 5000)
            if src ~= stocksply then
                TriggerClientEvent('QBCore:Notify', stocksply, 'You don\'t have enough Shares.', 'error', 5000)
            end
        end
    elseif type == 'Buy' and Player.PlayerData.money.bank >= (amount * worth) then
        if Player.Functions.RemoveMoney('bank', (amount * worth)) then
            if table.unpack(owned) ~= nil then
                plynewamount = tonumber(table.unpack(owned).amount) + amount
                MySQL.query("UPDATE `stocks` SET `amount` = "..plynewamount.." WHERE citizenid = @type AND type = @job_name", {['@type'] = citizenid, ['@job_name'] = job})
                TriggerClientEvent('QBCore:Notify', src, 'Shares Purchased.', 'success', 5000)
                if src ~= stocksply then
                    TriggerClientEvent('QBCore:Notify', stocksply, 'Shares Purchased.', 'success', 5000)
                end
                exports['qb-management']:AddMoney(job, (amount * worth))
            else
                MySQL.Async.insert('INSERT INTO stocks (`id`, `citizenid`, `type`, `amount`) VALUES (?, ?, ?, ?)', {math.random(22222,999999), citizenid, job, amount})
                TriggerClientEvent('QBCore:Notify', src, 'Shares Purchased.', 'success', 5000)
                if src ~= stocksply then
                    TriggerClientEvent('QBCore:Notify', stocksply, 'Shares Purchased.', 'success', 5000)
                end
                exports['qb-management']:AddMoney(job, (amount * worth))
            end
            Wait(Config.Values['refresh'] * 60000)
            IncreaseStock(job)
        else
            TriggerClientEvent('QBCore:Notify', src, 'You don\'t have enough money.', 'error', 5000)
            if src ~= stocksply then
                TriggerClientEvent('QBCore:Notify', stocksply, 'You don\'t have enough money.', 'error', 5000)
            end
        end
    end
end)

RegisterServerEvent('k-stocks:menuask', function(stocksply, broker)
    TriggerClientEvent('k-stocks:menuaskply', stocksply, stocksply, broker)
end)

RegisterServerEvent('k-stocks:approveapply', function(stocksply, broker)
    local src = stocksply
    TriggerClientEvent('k-stocks:Buymenu', broker, src, broker) 
end)

RegisterServerEvent('k-stocks:groupnotifycancel', function(stocksply, broker)
    local src = stocksply
    TriggerClientEvent('QBCore:Notify', src, "Transaction was cancelled", "error", 5000)
    if src ~= broker then
        TriggerClientEvent('QBCore:Notify', broker, "Transaction was cancelled", "error", 5000) 
    end
end)

QBCore.Functions.CreateCallback('k-stocks:returnstockvalues', function(source, cb, ply)
    local citizenid = QBCore.Functions.GetPlayer(ply).PlayerData.citizenid
    local owned = {}
    local businesses = MySQL.query.await('SELECT * FROM stock_funds WHERE 1', {})           
    local owned = MySQL.query.await('SELECT * FROM stocks WHERE citizenid = @cid', {['@cid'] = citizenid})
    cb({businesses = businesses, owned = owned})    
end) 