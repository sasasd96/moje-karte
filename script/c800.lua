--Paladion the Magna Warrior
--Custom card for EdoPro
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Special Summon by banishing 3 different "Magnet Warrior" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Redirect attack/target (Quick Effect)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.redcon1)
	e3:SetTarget(s.redtg1)
	e3:SetOperation(s.redop1)
	c:RegisterEffect(e3)
	--Redirect targeting effect (Quick Effect)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.redcon2)
	e4:SetTarget(s.redtg2)
	e4:SetOperation(s.redop2)
	c:RegisterEffect(e4)
	--Direct attack with modified damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
	--Modified battle damage
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e6:SetCondition(s.damcon)
	e6:SetValue(s.damval)
	c:RegisterEffect(e6)
end
s.listed_series={0x2066} --Magnet Warrior
--Special Summon limit
function s.splimit(e,se,sp,st)
	return se:GetHandler()==e:GetHandler()
end
--Special Summon condition filters
function s.spfilter(c)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c)
	return aux.SelectUnselectGroup(rg,e,tp,3,3,aux.dncheck,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_REMOVE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
--Redirect attack condition and operation
function s.redcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.redtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local at=Duel.GetAttackTarget()
		return at and Duel.IsExistingMatchingCard(Card.IsCanBeAttackTarget,tp,LOCATION_MZONE,LOCATION_MZONE,1,at,Duel.GetAttacker())
	end
end
function s.redop1(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	if not at then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanBeAttackTarget,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,at,Duel.GetAttacker())
	local tc=g:GetFirst()
	if tc then
		Duel.ChangeAttackTarget(tc)
	end
end
--Redirect targeting condition and operation
function s.redcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsOnField,1,nil)
end
function s.redtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tg=eg:GetFirst()
		return Duel.IsExistingMatchingCard(Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,tg)
	end
end
function s.redop2(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:GetFirst()
	if not tg then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,tg)
	local tc=g:GetFirst()
	if tc then
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
--Direct attack damage condition and value
function s.damcon(e)
	return Duel.GetAttackTarget()==nil
end
function s.damfilter(c)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4)
end
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	local ct1=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_REMOVED,0,nil)
	local ct2=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_GRAVE,0,nil)
	return (ct1+ct2)*300
end