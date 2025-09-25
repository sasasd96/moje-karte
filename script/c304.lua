--Toonfiscation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e1)
end
s.listed_names={15259703,43175858}
s.listed_series={0x62}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15259703),tp,LOCATION_ONFIELD,0,1,nil)
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,43175858),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x62),tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_HAND,1,1,nil)
		if #sg>0 then
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
		Duel.ShuffleHand(1-tp)
	end
end