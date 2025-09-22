--Archfiend Alternative Black Skull Dragon
--Scripted by OpenHands
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3B),aux.FilterBoolFunctionEx(Card.IsSetCard,0x45))
	--Take control of opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.ctrlcon)
	e1:SetTarget(s.ctrltg)
	e1:SetOperation(s.ctrlop)
	c:RegisterEffect(e1)
	--Special Summon Archfiend Black Skull Dragon when sent to GY by opponent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={18491580,45349196} --Red-Eyes Alternative Black Dragon, Archfiend Black Skull Dragon

function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterial():IsExists(Card.IsCode,1,nil,18491580)
		or c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.ctrlfilter(c,atk)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:GetDefense()<atk
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctrlfilter(chkc,c:GetAttack()) end
	if chk==0 then return Duel.IsExistingTarget(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if Duel.GetControl(tc,tp) then
			local atk=tc:GetAttack()
			--Destroy during End Phase
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.descon)
			e1:SetOperation(s.desop2)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,atk)
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp) then
		local atk=tc:GetFlagEffectLabel(id) or 0
		if Duel.Destroy(tc,REASON_EFFECT)>0 and atk>0 then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT) and rp==1-tp
end
function s.spfilter(c,e,tp)
	return c:IsCode(45349196) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		tc:SetStatus(STATUS_PROC_COMPLETE,true)
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end