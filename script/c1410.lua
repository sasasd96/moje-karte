--Doppelganger Token
--Custom token
local s,id=GetID()
function s.initial_effect(c)
	--Token
	aux.TokenRegister(c,id)
end