local QBCore = exports['qb-core']:GetCoreObject()
local listen = false

local function openMarket(source)
    local Buy = false
    local Buytitle = 'Open'
    local Sell = false
    local Selltitle = 'Open'
    local Trade = false
    local Tradetitle = 'Open'
    if Config.OpenTimes['Buy'].active then
        if GetClockHours() < Config.OpenTimes['Buy'].open or GetClockHours() > Config.OpenTimes['Buy'].close then
            Buy = true
            Buytitle = 'Closed'
        end
    elseif Config.OpenTimes['Sell'].active then
        if GetClockHours() < Config.OpenTimes['Sell'].open or GetClockHours() > Config.OpenTimes['Sell'].close then
            Sell = true
            Selltitle = 'Closed'
        end
    elseif Config.OpenTimes['Trade'].active then
        if GetClockHours() < Config.OpenTimes['Trade'].open or GetClockHours() > Config.OpenTimes['Trade'].close then
            Trade = true
            Tradetitle = 'Closed'
        end
    end
    exports['qb-menu']:openMenu({
        {
            header = "| "..Config.Blip['label'].." |",
            isMenuHeader = true, -- Set to true to make a nonclickable title
        },
        {
            header = "| Buy Stocks | "..Buytitle.." |",
            disabled = Buy,
            params = {
                event = "k-stocks:MarketMenu2",
                args = {
                    source = source,
                    type = 'Buy'
                }
            }
        },
        {
            header = "| Sell Stocks | "..Selltitle.." |",
            disabled = Sell,
            params = {
                event = "k-stocks:MarketMenu2",
                args = {
                    source = source,
                    type = 'Sell'
                }
            }
        },
        {
            header = "| Transfer Stocks | "..Tradetitle.." |",
            disabled = Trade,
            params = {
                event = "k-stocks:MarketMenu2",
                args = {
                    source = source,
                    type = 'Transfer'
                }
            }
        }
    })
end

local function Listen4Control()
    CreateThread(function()
        listen = true
        while listen do
            if IsControlJustPressed(0, 38) then -- E
                exports["qb-core"]:KeyPressed()
                local Player = QBCore.Functions.GetPlayerData()
                local source = Player.source
                TriggerEvent("k-stocks:openMarket")
                --openMarket(source)
                listen = false
                break
            end
            Wait(1)
        end
    end)
end

Citizen.CreateThread(function()
    Stock = AddBlipForCoord(Config.Blip['coords'].x, Config.Blip['coords'].y, Config.Blip['coords'].z)
    SetBlipSprite (Stock, Config.Blip['sprite'])
    SetBlipDisplay(Stock, 4)
    SetBlipScale  (Stock, Config.Blip['scale'])
    SetBlipAsShortRange(Stock, true)
    SetBlipColour(Stock, Config.Blip['color'])
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Blip['label'])
    EndTextCommandSetBlipName(Stock)
end) 

CreateThread(function()
    if not Config.Target['active'] then
        local zone = CircleZone:Create(Config.Blip['coords'], 2, {
            debugPoly = false,
            name = Config.Blip['label'],
            minZ = Config.Blip['coords'].z - 5.0,
            maxZ = Config.Blip['coords'].z + 5.0
        })
        zone:onPlayerInOut(function(isPointInside, _, zone)
            if Config.Target['job'] ~= 'all' then
                if Config.Target['job'] == QBCore.Functions.GetPlayerData().job.name then
                    if isPointInside then
                        exports["qb-core"]:DrawText("[E] Open "..Config.Blip['label'])
                        Listen4Control()
                    else
                        exports["qb-core"]:HideText()
                        listen = false
                    end
                end
            else
                if isPointInside then
                    exports["qb-core"]:DrawText("[E] Open "..Config.Blip['label'])
                    Listen4Control()
                else
                    exports["qb-core"]:HideText()
                    listen = false
                end
            end
        end)
    else
        exports['qb-target']:AddCircleZone(Config.Blip['label'], Config.Blip['coords'], 2, {
            name=Config.Blip['label'],
            minZ = Config.Blip['coords'].z - 5.0,
            maxZ = Config.Blip['coords'].z + 5.0
            --debugPoly=true
              }, {
            options = {
                {
                    event = "k-stocks:openMarket",
                    icon = Config.Target['icon'],
                    label = "Open "..Config.Blip['label']
                },
            },
            job = {Config.Target['job']},
            distance = 2.5
        })
    end
end)

RegisterNetEvent("k-stocks:openMarket", function()
    local Player = QBCore.Functions.GetPlayerData()
    local source = Player.source
    if Config.Target['job'] == 'all' then
        openMarket(source)
    elseif Config.Target['job'] == QBCore.Functions.GetPlayerData().job.name then
        local dialog = exports['qb-input']:ShowInput({
            header = "| Whos Stocks to View? |",
            submitText = "submit",
            inputs = {
                {
                    text = "Paypal ID",
                    name = "Amount",
                    type = "text",
                    isRequired = true,                
                }
            }
        })
        if dialog ~= nil then
            local person = tonumber(dialog['Amount'])
            TriggerServerEvent('k-stocks:menuask', source, person)
        else
            QBCore.Functions.Notify('You must set a valid amount!', 'error', 5000)
        end
    else
        QBCore.Functions.Notify('You must have a valid job!', 'error', 5000)
    end
end)

RegisterNetEvent('k-stocks:menuaskply', function(stocksply, broker)
    stockcheck = {
        {
            header = "| Allow stocks access? |",
            isMenuHeader = true
        },
        {
            header = "Aprrove stocks access",
            params = {
                event = 'k-stocks:doapp',
                args = {
                    check = true,
                    stocksply = stocksply,
                    broker = broker
                }
            }
        },
        {
            header = "Deny stocks access",
            params = {
                event = 'k-stocks:doapp',
                args = {
                    check = false,
                    stocksply = stocksply,
                    broker = broker
                }
            }
        }
    }
    exports['qb-menu']:openMenu(stockcheck)
end)

RegisterNetEvent('k-stocks:doapp', function(data)
    if data.check then
        TriggerServerEvent('k-stocks:approveapply', data.stocksply, data.broker)
    else
        TriggerServerEvent('k-stocks:groupnotifycancel', data.stocksply, data.broker)
    end
end)


RegisterNetEvent('k-stocks:Buymenu', function(stocksply, broker)
    openMarket(stocksply)
end)

RegisterNetEvent("k-stocks:MarketMenu2", function(data)
    local source = data.source
    local type = data.type
    local Buyoptions = {}
    QBCore.Functions.TriggerCallback('k-stocks:returnstockvalues', function(cb)
        local text = 'error'
        Buyoptions = {
            {
                header = "| "..type.." Stocks |",
                isMenuHeader = true
            }
        }
        for k,v in pairs(cb.businesses) do
            local restricted = false
            local jobcount = Config.Target['restrictedjobs']
            for u = 1,#jobcount,1 do
                if v.job_name == jobcount[u] then
                    restricted = true
                end
            end
            Wait(0)
            if not restricted then
                local away = false
                if type == 'Buy' then
                    if (tonumber(v.amount) - (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1))) < Config.Threashold['Buy'].low or (tonumber(v.amount) - (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1))) > Config.Threashold['Buy'].high then
                        away = true
                        text = "Unavailable to Buy"   
                    else           
                        text = "$"..(tonumber(v.amount) + (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1)))
                        away = false
                        value = (tonumber(v.amount) + (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1)))
                    end
                elseif type == 'Sell' then
                    if (tonumber(v.amount) - (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1))) < Config.Threashold['Sell'].low or (tonumber(v.amount) - (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1))) > Config.Threashold['Sell'].high then
                            away = true
                            text = "Unavailable to Sell"   
                        else
                            text = "$"..(tonumber(v.amount) - (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1)))  
                            away = false
                        value = (tonumber(v.amount) + (Config.Values['moveamount'] + math.floor((Config.Values['moveamount'] * 0.25) * 1)))
                    end
                else
                    text = "$"..v.amount   
                    away = false
                    value = tonumber(v.amount) 
                end    
                Buyoptions[#Buyoptions+1] = {
                    header = QBCore.Shared.Jobs[v.job_name].label,
                    txt = text,
                    disabled = away,
                    params = {
                        event = 'k-stocks:Marketinput',
                        args = {
                            ply = source,
                            job = v.job_name,
                            worth = value,
                            type = type
                        }
                    }
                }
            end
        end
        Buyoptions[#Buyoptions+1] = {
            
                header = "⇩ Owned Stocks ⇩ ",
                isMenuHeader = true
            
        }
        for i = 1,#cb.owned,1 do
            Buyoptions[#Buyoptions+1] = {                
                header = QBCore.Shared.Jobs[cb.owned[i].type].label.." Shares",
                txt = "Amount : "..cb.owned[i].amount,
                isMenuHeader = true                
            }
        end
        exports['qb-menu']:openMenu(Buyoptions)
    end, source)
end)

RegisterNetEvent('k-stocks:Marketinput', function(data)
    if data.type == 'Transfer' then
        local dialog = exports['qb-input']:ShowInput({
            header = "| Send Stocks |",
            submitText = "submit",
            inputs = {
                {
                    text = "Paypal ID",
                    name = "Who",
                    type = "text",
                    isRequired = true,                
                },
                {
                    text = "Amount",
                    name = "Amount",
                    type = "text",
                    isRequired = true,                
                }
            }
        })
        if dialog ~= nil then
            local who = tonumber(dialog['Who'])
            local price = tonumber(dialog['Amount'])
            TriggerServerEvent('k-stocks:Transfer', who, price, data.job, data.ply)
        else
            QBCore.Functions.Notify('You must set a valid amount!', 'error', 5000)
        end
    else  
        local dialog = exports['qb-input']:ShowInput({
            header = "| "..data.type.." Stocks |",
            submitText = "submit",
            inputs = {
                {
                    text = "Amount",
                    name = "Amount",
                    type = "text",
                    isRequired = true,                
                }
            }
        })
        if dialog ~= nil then
            local price = tonumber(dialog['Amount'])
            TriggerServerEvent('k-stocks:BuySell', price, data.job, data.type, tonumber(data.worth), data.ply)
        else
            QBCore.Functions.Notify('You must set a valid amount!', 'error', 5000)
        end
    end
end)