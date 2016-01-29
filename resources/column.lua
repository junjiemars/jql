local _t_n_ = '_T_N_'
local nk = table.getn(KEYS)
local na = table.getn(ARGV)

local def_table = function(t)
    local _t_t_ = string.format('_T_[%s]_', t)
    if (0 == redis.call('sismember', _t_n_, _t_t_)) then
        local s = redis.call('sadd', _t_n_, _t_t_)
        redis.debug(s)
    end 
    return _t_t_
end

local def_column = function(t, c, v)
    local cs = t..'C_'
    local cd = string.format(t..'[%s]_', c)
    if (1 == redis.call('sadd', cs, cd)) then
        redis.call('hset', cd, v)
    end
    return cd
end

local make_column = function(c, n, v)
    local d = redis.call('hset', c, n, v)
    return d
end

if (0 < nk) and (nk == na+2) then
    local t = def_table(KEYS[1])
    local cn = KEYS[2]
    local c = def_column(t, cn)
    if (2 < nk) then
        for i=3,nk do
            local n = KEYS[i]
            local v = ARGV[i-2]
            local d = make_column(c, n, v)
            redis.debug(d)
        end
        return 1
    end
end

return 0

--[[
local n = table.getn(ARGV)

if (2 <= n) then
  local t = ARGV[1]
  local c = ARGV[2]''
  local k = string.format('_T_[%s]', t)
  local s = k .. '_C_'

  if (1 == redis.call('sadd', s, c)) then
     return k .. '_[%s]_'
  end
end
--]]