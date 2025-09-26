--Chthonian Nightmare Rider
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND))
	
	--ATK gain from opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval1)
	c:RegisterEffect(e1)
	
	--ATK loss from own monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval2)
	c:RegisterEffect(e2)
	
	--Banish destroyer and damage when destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end

--Fusion material filter
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end

--ATK gain from opponent's monsters
function s.atkval1(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,nil)*200
end

--ATK loss from own monsters
function s.atkval2(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,c)*-500
end

--Damage condition
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end

--Damage target and operation
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
	if re then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,re:GetHandler(),1,0,0)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(re:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
	Duel.Damage(tp,500,REASON_EFFECT,true)
	Duel.Damage(1-tp,500,REASON_EFFECT,true)
	Duel.RDComplete()
end