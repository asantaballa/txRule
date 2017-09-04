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
, VotingRuleResult				Varchar(Max)
)
Go

Drop Table voting.#VotingCondition
Go

Create Table voting.#VotingCondition
( VotingConditionId			Int				--Identity(1,1)
, ProjectId					Int	Not Null
, VotingRuleId				Int		
, VotingFieldId				Int
, Operator					Varchar(16)
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
, (3, 'Claim_PriAmt'	, 'voting'	, 'Claim'	, 'PriAmt'		, @GT_Number)
, (4, 'Claim_SecAmt'	, 'voting'	, 'Claim'	, 'SecAmt'		, @GT_Number)

--Select * From voting.#VotingField

Insert Into voting.#VotingCondition
( VotingConditionId
, ProjectId
, VotingRuleId
, VotingFieldId
, Operator
, NumValue1
, NumValue2
, StrValue1
, StrValue2
)
Values
  ( 1, @ProjectId, 1, 1, 'Between',     0.00,   1000.00, Null, Null)
, ( 2, @ProjectId, 1, 1, 'Between',  1000.01,  10000.00, Null, Null)
, ( 3, @ProjectId, 1, 1, 'Between', 10000.01, 100000.00, Null, Null)
, ( 4, @ProjectId, 3, 2, 'Between',     0.00,   1000.00, Null, Null)
, ( 5, @ProjectId, 3, 2, 'Between',  1000.01,  10000.00, Null, Null)
, ( 6, @ProjectId, 3, 2, 'Between', 10000.01, 100000.00, Null, Null)
, ( 7, @ProjectId, 3, 3, 'Between',     0.00,   1000.00, Null, Null)
, ( 8, @ProjectId, 2, 3, 'Between',  1000.01,  10000.00, Null, Null)
, ( 9, @ProjectId, 2, 3, 'Between', 10000.01, 100000.00, Null, Null)
, (10, @ProjectId, 2, 4, 'Between',     Null,      Null, 'AZ', 'AZ')
, (11, @ProjectId, 2, 4, 'Between',     Null,      Null, 'FL', 'FL')

--Select * From  voting.#VotingCondition

Insert Into voting.#VotingRule
( VotingRuleId
, ProjectId
, VotingRuleName
, VotingRuleResult
)
Values
  (1, @ProjectId	, 'Rule for Plan class abc', '40')
, (2, @ProjectId	, 'Rule for Plan class bcd', '30')
, (3, @ProjectId	, 'Rule for Plan class cde', '20')
, (4, @ProjectId	, 'Rule for Plan class def', '10')

--Select * From  voting.#VotingRule

-- -- -- -- --


Declare @Alias Table
(
  TableName	Varchar(128)
, Alias		Varchar(128)
)

Insert into @Alias (TableName, Alias) Values
  ('Claim', 'clm')
, ('Voting', 'vote')

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

-- Cycle through Rules

Declare
  @vr_VotingRuleName	Varchar(64)
, @vr_VotingRuleResult	Varchar(Max)

Insert Into #Work_VotingRule Select *  From voting.#VotingRule vr 

Select @Curr_VotingRuleId = (Select Min(vr.VotingRuleId) From #Work_VotingRule vr)
While @Curr_VotingRuleId Is Not Null
Begin
	If (Select Count(*) From voting.#VotingCondition vc Where vc.VotingRuleId = @Curr_VotingRuleId) > 0
	Begin
		Select
		  @vr_VotingRuleName = vr.VotingRuleName
		, @vr_VotingRuleResult = vr.VotingRuleResult
		From #Work_VotingRule vr 
		Where vr.VotingRuleId = @Curr_VotingRuleId

		Insert Into @Sql (Stm) Select '        -- Rule: ' + @vr_VotingRuleName	
		Insert Into @Sql (Stm) Select '        When 1 = 1 '	

		-- Cycle through Conditions

		Insert Into #Work_VotingCondition Select * From voting.#VotingCondition vc Where vc.VotingRuleId = @Curr_VotingRuleId
		Select @Curr_VotingConditionId = (Select Min(vr.VotingConditionId) From #Work_VotingCondition vr)
		While @Curr_VotingConditionId Is Not Null
		Begin

			Insert into @Sql (Stm) 
			Select '          And ' 
					+ IsNull((Select Alias From @Alias als Where als.TableName = vf.VotingFieldDbTableName), vf.VotingFieldDbTableName)
					+ '.' + vf.VotingFieldDbFieldName + ' ' + vc.Operator + ' ' + IsNull(Cast(vc.NumValue1 As Varchar(128)), '???') + ' And ' + IsNull(Cast(vc.NumValue2 As Varchar(128)), '???')
			From		voting.#VotingCondition	vc 
			Inner Join	voting.#VotingField		vf	On vf.VotingFieldId = vc.VotingFieldId
			Where vc.VotingConditionId = @Curr_VotingConditionId

			Delete #Work_VotingCondition Where VotingConditionId = @Curr_VotingConditionId
			Select @Curr_VotingConditionId = (Select Min(vr.VotingConditionId) From #Work_VotingCondition vr)
		End

		Insert into @Sql (Stm) Select '        Then ' + @vr_VotingRuleResult
	End

	Delete #Work_VotingRule Where VotingRuleId = @Curr_VotingRuleId
	Select @Curr_VotingRuleId = (Select Min(vr.VotingRuleId) From #Work_VotingRule vr)
End

Select seq, Stm from @Sql Order By Seq

