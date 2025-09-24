--Black Illusion Capture Jar
--Custom card for EDOPro
local s,id=GetID()
function s.initial_effect(c)
	--Activate and equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Position lock
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.postg)
	c:RegisterEffect(e2)
	--Force Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.postg)
	e3:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={64631466}
s.listed_series={0x110,0x1110}
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and (c:IsCode(64631466) or c:IsSetCard(0x1110)) and c:IsType(TYPE_FUSION)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			if Duel.Equip(tp,tc,ec,false) then
				--Add Equip limit
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				e1:SetLabelObject(ec)
				tc:RegisterEffect(e1)
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			end
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.postg(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_MZONE,0,nil,tp)
	for tc in aux.Next(g) do
		local eq=tc:GetEquipGroup()
		for eqc in aux.Next(eq) do
			if eqc:GetFlagEffect(id)~=0 and eqc:IsType(c:GetType()&TYPE_MONSTER) then
				return true
			end
		end
	end
	return false
end
function s.spfilter(c,e,tp)
	return c:IsCode(603) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end