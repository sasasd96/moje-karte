--Ancient Piper
--Custom card for EDOPro
local s,id=GetID()
function s.initial_effect(c)
	--Ritual or Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={64631466}
s.listed_series={0x110,0x1110}
function s.ritualfilter(c,e,tp)
	return c:IsCode(64631466) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.tribfilter(c)
	return c:IsLevelAbove(1) and c:IsReleasable()
end
function s.fusfilter(c,e,tp,m,f,chkf)
	return c:IsSetCard(0x1110) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ritual_check=Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.tribfilter,tp,LOCATION_MZONE,0,1,nil)
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local fusion_check=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		return ritual_check or fusion_check
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ritual_check=Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.tribfilter,tp,LOCATION_MZONE,0,1,nil)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp)
	local fusion_check=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	
	local op=0
	if ritual_check and fusion_check then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif ritual_check then
		op=0
	elseif fusion_check then
		op=1
	else
		return
	end
	
	if op==0 then
		--Ritual Summon
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.ritualfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local mat=Duel.SelectMatchingCard(tp,s.tribfilter,tp,LOCATION_MZONE,0,1,1,nil)
			if #mat>0 then
				tc:SetMaterial(mat)
				Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
				tc:CompleteProcedure()
			end
		end
	else
		--Fusion Summon
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg1,nil,chkf)
		local tc=g:GetFirst()
		if tc then
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat)
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end