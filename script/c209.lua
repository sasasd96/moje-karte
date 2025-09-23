--Orichalcos Revival
local s,id=GetID()
function s.initial_effect(c)
	--Ritual summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rittg)
	e1:SetOperation(s.ritop)
	c:RegisterEffect(e1)
	--Cannot special summon from extra deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
end
s.listed_names={208}
s.listed_series={0x12ab}
function s.ritfilter(c,e,tp)
	return c:IsSetCard(0x12ab) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.mfilter(c)
	return c:IsSetCard(0x12ab) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ritfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if tc:IsCode(208) and Duel.GetLP(tp)>=10000 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			--Great Leviathan can use LP payment instead
			Duel.PayLPCost(tp,10000)
			tc:SetMaterial(nil)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		else
			--Normal ritual procedure
			local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,tc)
			local mat=mg:SelectWithSumGreater(tp,Card.GetLevel,tc:GetLevel())
			if #mat>0 then
				tc:SetMaterial(mat)
				Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
				tc:CompleteProcedure()
			end
		end
	end
end
function s.spcon(e)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end