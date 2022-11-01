Config = {}

Config.Target = {
    ['active'] = false,
    ['icon'] = 'fas fa-exchange',
    ['type'] = 'qb-target',
    ['job'] = 'all', -- can be set to bank or broker job
    ['restrictedjobs'] = {-- jobs whos funds will not be included in the stock market remember bought stocks fund a business
        'police',
        'ambulance',
    }
}
Config.Threashold = {
    ['Buy'] = {
        high = 100000000,
        low = math.random(500,1500) --lowest value the stock can be before the market closes
    },
    ['Sell'] = {
        high = math.random(75000,100000), --highest value the stock can be before the market closes
        low = 0
    }
}
Config.OpenTimes = {
    ['Buy'] = {
        active = false,
        open = 0,
        close = 24
    },
    ['Sell'] = {
        active = false,
        open = 0,
        close = 24
    },
    ['Trade'] = {
        active = false,
        open = 0,
        close = 24
    }
}
Config.Values = {
    ['goal'] = 0.10, -- percentage of the society funds that the stocks try to match 
    ['refresh'] = 5, -- minutes till it does math for the value of the stock
    ['moveamount'] = 100, -- value to move it by this number is not static this just gives the resource a general idea of where your economy is set
}
Config.Blip = {
    ['coords'] = vector3(249.04, 212.44, 106.29),--location of the stock market
    ['label'] = 'Wall Street',--label of the blip
    ['sprite'] = 5,--sprite of the blip
    ['color'] = 75,--color of the blip
    ['scale'] = 0.2,--scale of the blip
}