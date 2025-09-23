--Helios Quintet Megistus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Unaffected by opponent's card effects while Macro Cosmos is on field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(s.immcon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--ATK/DEF based on banished cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e4)
	--Multiple attacks
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e5:SetValue(2)
	c:RegisterEffect(e5)
	--Banish opponent's deck on summon
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetTarget(s.rmtg)
	e6:SetOperation(s.rmop)
	c:RegisterEffect(e6)
end
s.listed_names={54493213,80887952,17286057,30241314} --Helios monsters + Macro Cosmos

function s.spfilter(c)
	return (c:IsCode(54493213) or c:IsCode(80887952) or c:IsCode(17286057)) and c:IsAbleToDeck()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	return g:IsExists(Card.IsCode,1,nil,54493213) and g:IsExists(Card.IsCode,1,nil,80887952) and g:IsExists(Card.IsCode,1,nil,17286057)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	local sg=Group.CreateGroup()
	--Select one of each required Helios monster
	local helios1=g:Filter(Card.IsCode,nil,54493213):GetFirst()
	local helios2=g:Filter(Card.IsCode,nil,80887952):GetFirst()
	local helios3=g:Filter(Card.IsCode,nil,17286057):GetFirst()
	if helios1 then sg:AddCard(helios1) end
	if helios2 then sg:AddCard(helios2) end
	if helios3 then sg:AddCard(helios3) end
	if #sg==3 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
		g:DeleteGroup()
	end
end

function s.immcon(e)
	return Duel.IsExistingMatchingCard(s.macrofilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

function s.macrofilter(c)
	return c:IsFaceup() and c:IsCode(30241314)
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end