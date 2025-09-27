--Diamond-Head Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Special Summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--ATK becomes tributed monster's ATK + 1000
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Negate and destroy Spell/Trap that target this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetOperation(s.negtg)
	c:RegisterEffect(e4)
end

function s.splimit(e,se,sp,st)
	return se:GetHandler()==e:GetHandler()
end

function s.spfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControler(tp) and not c:IsCode(id)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.spfilter,nil,tp)
	if chk==0 then return #g>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,tc,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
			--Store the tributed monster's ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetAttack()+1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end

function s.atkval(e,c)
	return e:GetHandler():GetFlagEffectLabel(id) or 0
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if rc:IsType(TYPE_SPELL+TYPE_TRAP) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		Duel.NegateEffect(ev)
		Duel.Destroy(rc,REASON_EFFECT)
	end
end