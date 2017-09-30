Drop Table rules.#Field
Go

Create Table rules.#Field
( FieldId				Int				--Identity(1,1)
--, ProjectId					Int	Not Null
, FieldCode			Varchar(64)
, FieldDbSchemaName	Varchar(128)
, FieldDbTableName	Varchar(128)
, FieldDbFieldName	Varchar(128)
, FieldGenericType	Int
)
Go

Drop Table rules.#RuleSet
Go

Create Table rules.#RuleSet
( RuleSetId			Int				--Identity(1,1)
, ProjectId			Int	Not Null
, RuleSetName			Varchar(64)
, RuleSetResult		Varchar(Max)
)
Go

Drop Table rules.#Rule
Go

Create Table rules.#Rule
( ConditionId		Int				--Identity(1,1)
, ProjectId			Int	Not Null
, RuleSetId			Int		
, FieldId			Int
, Operator			Varchar(16)
, NumValue1			Decimal(38, 8)
, NumValue2			Decimal(38, 8)
, StrValue1			Varchar(MAX)
, StrValue2			
Varchar(MAX)
)
Go

Drop Table rules.#PlanClassRuleRelation
Go

Create Table .#PlanClassRuleRelation
( PlanClassRuleRelationId	Int	Identity(1,1)
, PlanClassId				Int	Not Null
, RuleSetId					Int	Not Null
)
Go

-- -- -- -- -- --

Declare
  @GT_Undefined	Int	= 0
, @GT_Character	Int	= 1
, @GT_Number	Int	= 2

Declare 
  @ProjectId	Int	= 1234

Insert Into rules.#Field
( FieldId
, FieldCode
, FieldDbSchemaName
, FieldDbTableName
, FieldDbFieldName
, FieldGenericType
)
Values
  (1, 'Claim_AdminAmt'	, ''	, 'Claim'	, 'AdminAmt'	, @GT_Number)
, (2, 'Claim_SecAmt'	, ''	, 'Claim'	, 'SecAmt'		, @GT_Number)
, (3, 'Claim_PriAmt'	, ''	, 'Claim'	, 'PriAmt'		, @GT_Number)
, (4, 'Claim_SecAmt'	, ''	, 'Claim'	, 'SecAmt'		, @GT_Number)

--Select * From rules.#Field

Insert Into rules.#Rule
( ConditionId
, ProjectId
, RuleSetId
, FieldId
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

--Select * From  rules.#Rule

Insert Into rules.#RuleSet
( RuleSetId
, ProjectId
, RuleSetName
, RuleSetResult
)
Values
  (1, @ProjectId	, 'Rule for Plan class abc', '40')
, (2, @ProjectId	, 'Rule for Plan class bcd', '30')
, (3, @ProjectId	, 'Rule for Plan class cde', '20')
, (4, @ProjectId	, 'Rule for Plan class def', '10')

--Select * From  rules.#RuleSet

-- -- -- -- --

Declare @Alias Table
(
  TableName	Varchar(128)
, Alias		Varchar(128)
)

Insert into @Alias (TableName, Alias) Values
  ('Claim', 'clm')
, ('', 'vote')

Declare @Sql Table
(
  Seq Int Identity(1,1)
, Stm Varchar(Max)
)

Insert into @Sql (Stm) 
			Select 'Delete Table'
Union All	Select 'Where ProjectId = ' + Cast(@ProjectId As Varchar(128))
Union All	Select ' '
Union All	Select 'Update Table'
Union All	Select 'Set PlanClassId ='
Union All	Select '    Case'

Drop Table #Work_RuleSet
Select * Into #Work_RuleSet From rules.#RuleSet vr Where 1 = 0
Declare @Curr_RuleSetId Int

Drop Table #Work_Rule
Select * Into #Work_Rule From rules.#Rule vf  Where 1 = 0
Declare @Curr_ConditionId Int

-- Cycle through Rulesets

Declare
  @vr_RuleSetName	Varchar(64)
, @vr_RuleSetResult	Varchar(Max)

Insert Into #Work_RuleSet Select *  From rules.#RuleSet vr 

Select @Curr_RuleSetId = (Select Min(vr.RuleSetId) From #Work_RuleSet vr)
While @Curr_RuleSetId Is Not Null
Begin
	If (Select Count(*) From rules.#RuleSet vc Where vc.RuleSetId = @Curr_RuleSetId) > 0
	Begin
		Select
		  @vr_RuleSetName = vr.RuleSetName
		, @vr_RuleSetResult = vr.RuleSetResult
		From #Work_RuleSet vr 
		Where vr.RuleSetId = @Curr_RuleSetId

		Insert into @Sql (Stm) Values('')
		Insert Into @Sql (Stm) Select '        -- Rule: ' + @vr_RuleSetName	
		Insert Into @Sql (Stm) Select '        When 1 = 1 '	

		-- Cycle through Conditions

		Insert Into #Work_Rule Select * From rules.#Rule vc Where vc.RuleSetId = @Curr_RuleSetId
		Select @Curr_ConditionId = (Select Min(vr.ConditionId) From #Work_Rule vr)
		While @Curr_ConditionId Is Not Null
		Begin

			Insert into @Sql (Stm) 
			Select '          And ' 
					+ IsNull((Select Alias From @Alias als Where als.TableName = vf.FieldDbTableName), vf.FieldDbTableName)
					+ '.' + vf.FieldDbFieldName + ' ' + vc.Operator + ' ' + IsNull(Cast(vc.NumValue1 As Varchar(128)), '???') + ' And ' + IsNull(Cast(vc.NumValue2 As Varchar(128)), '???')
			From		rules.#Rule	vc 
			Inner Join	rules.#Field		vf	On vf.FieldId = vc.FieldId
			Where vc.ConditionId = @Curr_ConditionId

			Delete #Work_Rule Where ConditionId = @Curr_ConditionId
			Select @Curr_ConditionId = (Select Min(vr.ConditionId) From #Work_Rule vr)
		End

		Insert into @Sql (Stm) Select '        Then ' + @vr_RuleSetResult
	End

	Delete #Work_RuleSet Where RuleSetId = @Curr_RuleSetId
	Select @Curr_RuleSetId = (Select Min(vr.RuleSetId) From #Work_RuleSet vr)
End

Select Stm from @Sql Order By Seq

