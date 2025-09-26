--Spirit Illusion
--Custom card
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	--Destroy token when this card leaves field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_series={0x1300}
function s.eqlimit(e,c)
	return c:IsSetCard(0x1300) or aux.IsCodeListed(c,1307)
end
function s.filter(c)
	return c:IsFaceup() and (c:IsSetCard(0x1300) or aux.IsCodeListed(c,1307))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
		--Create token
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			local token=Duel.CreateToken(tp,id+100)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(tc:GetType())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			token:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetValue(tc:GetAttribute())
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			token:RegisterEffect(e2)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetValue(tc:GetLevel())
			e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			token:RegisterEffect(e3)
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_SET_ATTACK)
			e4:SetValue(tc:GetAttack())
			e4:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			token:RegisterEffect(e4)
			local e5=Effect.CreateEffect(e:GetHandler())
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_SET_DEFENSE)
			e5:SetValue(tc:GetDefense())
			e5:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			token:RegisterEffect(e5)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			e:GetHandler():SetCardTarget(token)
		end
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end