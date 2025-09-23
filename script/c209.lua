--Orichalcos Revival
local s,id=GetID()
function s.initial_effect(c)
	--Ritual summon
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsSetCard,0x12ab),nil,aux.Stringid(id,0),nil,s.mfilter,nil,s.location)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Alternative ritual summon for Great Leviathan
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rittg2)
	e2:SetOperation(s.ritop2)
	c:RegisterEffect(e2)
	--Cannot special summon from extra deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetCondition(s.spcon)
	c:RegisterEffect(e3)
end
s.listed_names={208}
s.listed_series={0x12ab}
function s.mfilter(c)
	return c:IsSetCard(0x12ab) and c:IsType(TYPE_MONSTER)
end
function s.location(e,tp,chk)
	if chk==0 then return LOCATION_HAND+LOCATION_GRAVE end
	return LOCATION_HAND+LOCATION_GRAVE
end
function s.ritfilter2(c,e,tp)
	return c:IsCode(208) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.rittg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ritfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLP(tp)>=10000 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.ritop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(tp)<10000 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ritfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.PayLPCost(tp,10000)
		tc:SetMaterial(nil)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.spcon(e)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end