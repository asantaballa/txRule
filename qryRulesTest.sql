Drop Table voting.#VotingField
Go

Create Table voting.#VotingField
( VotingFieldId				Int				--Identity(1,1)
--, ProjectId					Int	Not Null
, VotingFieldCode			Varchar(64)
, VotingFieldDbSchemaName	Varchar(128)
, VotingFieldDbTableName	Varchar(128)
, VotingFieldDbFieldName	Varchar(128)
, VotingFieldGenericType	Int
)
Go

Drop Table voting.#VotingRule
Go

Create Table voting.#VotingRule
( VotingRuleId				Int				--Identity(1,1)
, ProjectId					Int	Not Null
, VotingRuleName			Varchar(64)
)
Go

Drop Table voting.#VotingCondition
Go

Create Table voting.#VotingCondition
( VotingConditionId			Int				--Identity(1,1)
, ProjectId					Int	Not Null
, VotingFieldId				Int
, NumValue1					Decimal(38, 8)
, NumValue2					Decimal(38, 8)
, StrValue1					Varchar(MAX)
, StrValue2					Varchar(MAX)
)
Go

Drop Table voting.#VotingPlanClassRuleRelation
Go

Create Table voting.#VotingPlanClassRuleRelation
( VotingPlanClassRuleRelationId	Int	Identity(1,1)
, VotingPlanClassId				Int	Not Null
, VotingRuleId					Int	Not Null
)
Go

-- -- -- -- -- --

Declare
  @GT_Undefined	Int	= 0
, @GT_Character	Int	= 1
, @GT_Number	Int	= 2

Declare 
  @ProjectId	Int	= 1234

Insert Into voting.#VotingField
( VotingFieldId
, VotingFieldCode
, VotingFieldDbSchemaName
, VotingFieldDbTableName
, VotingFieldDbFieldName
, VotingFieldGenericType
)
Values
  (1, 'Claim_AdminAmt'	, 'voting'	, 'Claim'	, 'AdminAmt'	, @GT_Number)
, (2, 'Claim_SecAmt'	, 'voting'	, 'Claim'	, 'SecAmt'		, @GT_Number)
, (2, 'Claim_PriAmt'	, 'voting'	, 'Claim'	, 'PriAmt'		, @GT_Number)
, (2, 'Claim_SecAmt'	, 'voting'	, 'Claim'	, 'SecAmt'		, @GT_Number)

--Select * From voting.#VotingField

Insert Into voting.#VotingCondition
( VotingConditionId
, ProjectId
, VotingFieldId
, NumValue1
, NumValue2
, StrValue1
, StrValue2
)
Values
  ( 1, @ProjectId, 1,     0.00,   1000.00, Null, Null)
, ( 2, @ProjectId, 1,  1000.01,  10000.00, Null, Null)
, ( 3, @ProjectId, 1, 10000.01, 100000.00, Null, Null)
, ( 4, @ProjectId, 2,     0.00,   1000.00, Null, Null)
, ( 5, @ProjectId, 2,  1000.01,  10000.00, Null, Null)
, ( 6, @ProjectId, 2, 10000.01, 100000.00, Null, Null)
, ( 7, @ProjectId, 3,     0.00,   1000.00, Null, Null)
, ( 8, @ProjectId, 3,  1000.01,  10000.00, Null, Null)
, ( 9, @ProjectId, 3, 10000.01, 100000.00, Null, Null)
, (10, @ProjectId, 4,     Null,      Null, 'AZ', 'AZ')
, (11, @ProjectId, 4,     Null,      Null, 'FL', 'FL')

--Select * From  voting.#VotingCondition

Insert Into voting.#VotingRule
( VotingRuleId
, ProjectId
, VotingRuleName
)
Values
  (1, @ProjectId	, 'Rule for Plan class abc')
, (2, @ProjectId	, 'Rule for Plan class bcd')
, (3, @ProjectId	, 'Rule for Plan class cde')

--Select * From  voting.#VotingRule

-- -- -- -- --


Declare @Sql Table
(
  Seq Int Identity(1,1)
, Stm Varchar(Max)
)

Insert into @Sql (Stm) 
			Select 'Update VotingTable'
Union All	Select 'Set PlanClassId ='
Union All	Select '    Case'

Drop Table #Work_VotingRule
Select * Into #Work_VotingRule From voting.#VotingRule vr Where 1 = 0
Declare @Curr_VotingRuleId Int

Drop Table #Work_VotingCondition
Select * Into #Work_VotingCondition From voting.#VotingCondition vf  Where 1 = 0
Declare @Curr_VotingConditionId Int

Select @Curr_VotingRuleId = (Select Min(vr.VotingRuleId) From #Work_VotingRule vr)
While @Curr_VotingRuleId Is Not Null
Begin
	Insert into @Sql (Stm) Select '        When 1 = 1 ' 

	Select @Curr_VotingConditionId = (Select Min(vr.VotingConditionId) From #Work_VotingCondition vr)
	While @Curr_VotingConditionId Is Not Null
	Begin
		--Insert into @Sql (Stm) Select '        When 1 = 1 ' 
		--Insert into @Sql (Stm) Select '        Then ' 

		Insert into @Sql (Stm) 
		Select '  And ' + vf.VotingFieldDbFieldName + ' Between ' + Cast(vc.NumValue1 As Varchar(128)) + ' And ' + Cast(vc.NumValue2 As Varchar(128))
		From			voting.#VotingCondition	vc 
		Left Outer Join voting.#VotingField		vf	On vf.VotingFieldId = vc.VotingFieldId
		Where vc.VotingConditionId = @Curr_VotingConditionId

		Delete #Work_VotingCondition Where VotingConditionId = @Curr_VotingConditionId
		Select @Curr_VotingConditionId = (Select Min(vr.VotingConditionId) From #Work_VotingCondition vr)
	End

	Insert into @Sql (Stm) Select '        Then ' 
	Delete #Work_VotingRule Where VotingRuleId = @Curr_VotingRuleId
	Select @Curr_VotingRuleId = (Select Min(vr.VotingRuleId) From #Work_VotingRule vr)
End





--Insert into @Sql (Stm) 
--Select '  When 1 = 1 ' 
--Union All 
--Select 'Then ' 
--From			voting.#VotingRule vr


Select Stm from @Sql Order By Seq

