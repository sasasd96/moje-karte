--Alchemy Beast - Moonface the Silver
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Normal Summoned/Set
	c:EnableUnsummonable()
	--Must be Special Summoned with the effect of "Silver Key"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Reveal in hand to activate Chaos Distill
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.revealcost)
	e2:SetTarget(s.revealtg)
	e2:SetOperation(s.revealop)
	c:RegisterEffect(e2)
	--Direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	--If banished: Activate Attribute Absorber
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.acttg)
	e4:SetOperation(s.actop)
	c:RegisterEffect(e4)
end
s.listed_names={7,18} --Chaos Distill, Attribute Absorber
s.listed_series={0x501} --Alchemy Beast

function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(11) --Silver Key
end

function s.revealcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToShuffleIntoDeck() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.revealtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,7),tp,LOCATION_DECK,0,1,nil) end
end

function s.revealop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local tc=Duel.GetFirstMatchingCard(aux.FilterFaceupFunction(Card.IsCode,7),tp,LOCATION_DECK,0,nil)
		if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			Duel.ShuffleDeck(tp)
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

function s.actfilter(c,tp)
	return c:IsCode(18) and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK)) and c:GetActivateEffect():IsActivatable(tp,true)
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if fc<=0 then return end
		if tc:IsLocation(LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end