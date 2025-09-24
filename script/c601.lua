--Black Illusionist
--Custom card for EDOPro
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	c:RegisterEffect(e1)
	--Search on summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Draw on tribute/fusion material
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	e5:SetCondition(s.drcon2)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(s.drcon3)
	c:RegisterEffect(e6)
end
s.listed_names={64631466}
s.listed_series={0x110,0x1110}
function s.indtg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.tgfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttack(0) and c:IsAbleToGrave()
end
function s.thfilter(c)
	return (c:IsCode(64631466) or (c:IsRace(RACE_ILLUSION) and c:IsDefense(0))) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g1>0 and Duel.SendtoGrave(g1,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_RELEASE~=0
end
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_FUSION~=0
end
function s.drcon3(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_FUSION~=0
end
function s.drfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and (c:IsCode(64631466) or c:IsSetCard(0x110,0x1110)) 
		and not c:IsType(TYPE_NORMAL) and c:GetEquipCount()>0
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) 
		and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,0,nil,tp)
	if ct>0 then
		local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil,tp)
		local maxct=0
		for tc in aux.Next(g) do
			if tc:GetEquipCount()>maxct then
				maxct=tc:GetEquipCount()
			end
		end
		Duel.SetTargetParam(maxct)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,maxct)
	end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end