--Diabound LV4
--Custom card
local s,id=GetID()
function s.initial_effect(c)
	--Equip to monster or unequip and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE+LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Reduce ATK and negate effects when equipped
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	--Special Summon LV5 or listed monster when equipped monster is destroyed
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={1306}
function s.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
	if c:IsLocation(LOCATION_MZONE) then
		if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	else
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		local tc=Duel.GetFirstTarget()
		if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			if Duel.Equip(tp,c,tc) then
				--Add Equip limit
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				e1:SetLabelObject(tc)
				c:RegisterEffect(e1)
			end
		end
	else
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.atkval(e,c)
	return -e:GetHandler():GetAttack()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget()
		and c:IsReason(REASON_LOST_TARGET)
end
function s.spfilter1(c,e,tp)
	return c:IsCode(1306) and c:IsCanBeSpecialSummoned(e,1307,tp,false,false)
end
function s.spfilter2(c,e,tp,tc)
	return tc:IsHasEffect(EFFECT_ADD_CODE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		local b2=false
		local tc=e:GetHandler():GetPreviousEquipTarget()
		if tc then
			local eff=tc:IsHasEffect(EFFECT_ADD_CODE)
			if eff then
				local code=eff:GetValue()
				b2=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,code),tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
					and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,tc)
			end
		end
		return b1 or b2
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	local b2=false
	local tc=e:GetHandler():GetPreviousEquipTarget()
	if tc then
		local eff=tc:IsHasEffect(EFFECT_ADD_CODE)
		if eff then
			local code=eff:GetValue()
			b2=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,code),tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,tc)
		end
	end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	else
		op=1
	end
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,1307,tp,tp,false,false,POS_FACEUP)
		end
	else
		local eff=tc:IsHasEffect(EFFECT_ADD_CODE)
		local code=eff:GetValue()
		Duel.SendtoGrave(tc,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsCode,code),tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end