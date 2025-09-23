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
	--ATK/DEF based on banished cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3)
	--Multiple attacks
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(2)
	c:RegisterEffect(e4)
	--Banish opponent's deck on summon
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end

function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetAttack()==c:GetDefense() and c:IsAbleToDeck()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
	local sg=Group.CreateGroup()
	local codes={}
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetCode()
		if not codes[code] then
			codes[code]=true
			sg:AddCard(tc)
		end
		tc=g:GetNext()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=sg:Select(tp,3,3,nil)
	if tg then
		tg:KeepAlive()
		e:SetLabelObject(tg)
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