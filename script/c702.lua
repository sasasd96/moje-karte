--Ojamanjome
local s,id=GetID()
function s.initial_effect(c)
	--Can only control 1
	c:SetUniqueOnField(1,0,id)
	
	--Special Summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	
	--Add "Ojama" card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	
	--ATK gain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	
	--Attack all monsters
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ATTACK_ALL)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
s.listed_series={0xF}

--Special Summon condition
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and (#g==0 or g:IsExists(Card.IsSetCard,#g,nil,0xF))
end

--Add "Ojama" card
function s.thfilter(c)
	return c:IsSetCard(0xF) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleDeck(tp)
			--Check if it's Ojama Trio or Ojama Duo and can be activated directly from hand
			if (tc:IsCode(29843091) or tc:IsCode(14470845)) and tc:IsLocation(LOCATION_HAND) then
				if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.BreakEffect()
					if tc:IsCode(29843091) then --Ojama Trio
						s.ojama_trio_op(e,tp,eg,ep,ev,re,r,rp)
					elseif tc:IsCode(14470845) then --Ojama Duo
						s.ojama_duo_op(e,tp,eg,ep,ev,re,r,rp)
					end
					Duel.SendtoGrave(tc,REASON_EFFECT)
				end
			end
		end
	end
end

--Ojama Trio effect
function s.ojama_trio_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>=3 then
		local token=Duel.CreateToken(tp,29843091+100)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_DEF)
		local token2=Duel.CreateToken(tp,29843091+100)
		Duel.SpecialSummonStep(token2,0,tp,1-tp,false,false,POS_DEF)
		local token3=Duel.CreateToken(tp,29843091+100)
		Duel.SpecialSummonStep(token3,0,tp,1-tp,false,false,POS_DEF)
		Duel.SpecialSummonComplete()
	end
end

--Ojama Duo effect  
function s.ojama_duo_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>=2 then
		local token=Duel.CreateToken(tp,14470845+100)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_DEF)
		local token2=Duel.CreateToken(tp,14470845+100)
		Duel.SpecialSummonStep(token2,0,tp,1-tp,false,false,POS_DEF)
		Duel.SpecialSummonComplete()
	end
end

--ATK gain
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0xF),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
s.listed_series={0xF}
s.listed_names={29843091,14470845}