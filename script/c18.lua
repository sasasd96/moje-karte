--Attribute Absorber
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Negate attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--Negate effects of monsters with same attribute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e4)
end
s.listed_names={7} --Chaos Distill

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,7),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.GetAttacker():IsControler(1-tp)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end

function s.discon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,7),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		and s.attrcheck(e:GetHandlerPlayer())
end

function s.attrcheck(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_REMOVED,0,nil)
	local attrs=0
	for tc in aux.Next(g) do
		if tc:IsMonster() then
			attrs=attrs|tc:GetAttribute()
		end
	end
	local ct=0
	for i=0,6 do
		if attrs&(1<<i)~=0 then
			ct=ct+1
		end
	end
	return ct>=4
end

function s.distg(e,c)
	if not c:IsMonster() then return false end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_REMOVED,0,nil)
	for tc in aux.Next(g) do
		if c:IsAttribute(tc:GetAttribute()) then
			return true
		end
	end
	return false
end