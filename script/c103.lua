--Red Eyes Flame Swordsman
--Scripted by OpenHands
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand by targeting Red-Eyes monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Equip monster from Deck/Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--Destroy if ATK becomes 0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_names={}

function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3B) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			--This card loses 600 ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
			--Target gains 600 ATK
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(600)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
function s.eqfilter(c)
	return c:IsLevelBelow(7) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
function s.eqtarget(c)
	return c:IsFaceup() and c:IsSetCard(0x3B) and not c:IsCode(id)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqtarget(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:GetAttack()>=600 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqtarget,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqtarget,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		--This card loses exactly 600 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		--Select and equip monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
		if #g>0 then
			local ec=g:GetFirst()
			if Duel.Equip(tp,ec,tc) then
				--Equip limit
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_EQUIP_LIMIT)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(s.eqlimit)
				e2:SetLabelObject(tc)
				ec:RegisterEffect(e2)
				--ATK increase
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_EQUIP)
				e3:SetCode(EFFECT_UPDATE_ATTACK)
				e3:SetValue(600)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e3)
			end
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttack()==0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end