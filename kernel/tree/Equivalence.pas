unit Equivalence;

interface

implementation

uses
  SysUtils,
  DelphiAST.Classes, DelphiAST.Consts,
  TreeIntf
{$IFDEF UNITTEST}
  , TestFramework
{$ENDIF}
;

type
  TPrimitiveEquivalenceChecker = class(TInterfacedObject, IEquivalenceChecker)
  private
    function AttributeEqual(
      const AAtribute1: TAttributeEntry;
      const AAtribute2: TAttributeEntry): Boolean;

    function AttributesEqual(
      const AAttributes1: TArray<TAttributeEntry>;
      const AAttributes2: TArray<TAttributeEntry>): Boolean;
  protected
    function Equal(const ANode1: TSyntaxNode; const ANode2: TSyntaxNode): Boolean;
  end;

{$IFDEF UNITTEST}
  // Test for class TPrimitiveEquivalenceChecker
  TestTPrimitiveEquivalenceChecker = class(TTestCase)
  strict private
    FSUT: TPrimitiveEquivalenceChecker;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAttributeEqual;
    procedure TestAttributesEqual;
    procedure TestEqual;
  end;
{$ENDIF}

{ TPrimitiveEquivalenceChecker }

function TPrimitiveEquivalenceChecker.AttributeEqual(const AAtribute1, AAtribute2: TAttributeEntry): Boolean;
begin
  Result := (AAtribute1.Key = AAtribute2.Key) and (AAtribute1.Value = AAtribute2.Value)
end;

function TPrimitiveEquivalenceChecker.AttributesEqual(const AAttributes1,
  AAttributes2: TArray<TAttributeEntry>): Boolean;
var
  I: Integer;
  Delta: Integer;
begin
  if Length(AAttributes1) <> Length(AAttributes2) then
    Exit(False);

  Delta := Low(AAttributes2) - Low(AAttributes1);
  for I := Low(AAttributes1) to High(AAttributes1) do
    if not AttributeEqual(AAttributes1[I], AAttributes2[I + Delta]) then
      Exit(False);

  Result := True;
end;

function TPrimitiveEquivalenceChecker.Equal(const ANode1, ANode2: TSyntaxNode): Boolean;
begin
  if ANode1.Typ <> ANode2.Typ then
    Exit(False);

  if not AttributesEqual(ANode1.Attributes, ANode2.Attributes) then
    Exit(False);

  if ANode1.ClassType <> ANode2.ClassType then
    Exit(False);

  if (ANode1 is TValuedSyntaxNode) and (TValuedSyntaxNode(ANode1).Value <> TValuedSyntaxNode(ANode2).Value) then
      Exit(False);

  Result := True;
end;

{$IFDEF UNITTEST}
{ TestTPrimitiveEquivalenceChecker }

procedure TestTPrimitiveEquivalenceChecker.SetUp;
begin
  inherited;
  FSUT := TPrimitiveEquivalenceChecker.Create;
end;

procedure TestTPrimitiveEquivalenceChecker.TearDown;
begin
  inherited;
  FreeAndNil(FSUT);
end;

procedure TestTPrimitiveEquivalenceChecker.TestAttributeEqual;
var
  Atribute: TAttributeEntry;
begin
  Atribute := TAttributeEntry.Create(anType, 'class');

  CheckTrue(FSUT.AttributeEqual(Atribute, Atribute), 'Attribute should be equal to itself.');

  CheckTrue(FSUT.AttributeEqual(
    TAttributeEntry.Create(anType, 'class'),
    TAttributeEntry.Create(anType, 'class')),
    'Attributes should be equal.');

  CheckFalse(FSUT.AttributeEqual(
    TAttributeEntry.Create(anType, 'var'),
    TAttributeEntry.Create(anType, 'const')),
    'Attributes shouldnt be equal.');
end;


procedure TestTPrimitiveEquivalenceChecker.TestAttributesEqual;
begin
  CheckTrue(FSUT.AttributesEqual(
    TArray<TAttributeEntry>.Create(),
    TArray<TAttributeEntry>.Create()),
    'Empty attibutes should be equal');

  CheckTrue(FSUT.AttributesEqual(
    TArray<TAttributeEntry>.Create(TAttributeEntry.Create(anType, 'class'), TAttributeEntry.Create(anName, 'TObject')),
    TArray<TAttributeEntry>.Create(TAttributeEntry.Create(anType, 'class'), TAttributeEntry.Create(anName, 'TObject'))),
    'Attibutes should be equal');

  CheckFalse(FSUT.AttributesEqual(
    TArray<TAttributeEntry>.Create(TAttributeEntry.Create(anType, 'class'), TAttributeEntry.Create(anName, 'TObject')),
    TArray<TAttributeEntry>.Create(TAttributeEntry.Create(anType, 'class'), TAttributeEntry.Create(anName, 'TComponent'))),
    'Attibutes shouldnt be equal');

  CheckFalse(FSUT.AttributesEqual(
    TArray<TAttributeEntry>.Create(TAttributeEntry.Create(anType, 'class'), TAttributeEntry.Create(anName, 'TObject')),
    TArray<TAttributeEntry>.Create(TAttributeEntry.Create(anType, 'class'))),
    'Attibutes with different element count shouldnt be equal');
end;

procedure TestTPrimitiveEquivalenceChecker.TestEqual;
var
  Node1: TSyntaxNode;
  Node2: TSyntaxNode;

  ValuedNode1: TValuedSyntaxNode;
  ValuedNode2: TValuedSyntaxNode;
begin
  Node1 := TSyntaxNode.Create(ntIdentifier);
  Node1.SetAttribute(anName, 'foo');

  Node2 := Node1.Clone;

  ValuedNode1 := TValuedSyntaxNode.Create(ntLiteral);
  ValuedNode1.SetAttribute(anType, 'numeric');
  ValuedNode1.Value := '0';

  ValuedNode2 := ValuedNode1.Clone as TValuedSyntaxNode;
  ValuedNode2.Value := '1';

  try
    CheckTrue(FSUT.Equal(Node1, Node2),
      'Nodes should be equal');

    Node2.ClearAttributes;
    CheckFalse(FSUT.Equal(Node1, Node2),
      'Nodes with different attributes shouldnt be equal');

    CheckFalse(FSUT.Equal(Node1, ValuedNode1),
      'Different classes nodes shouldnt be equal');

    CheckFalse(FSUT.Equal(ValuedNode1, ValuedNode2),
      'nodes with different values shouldnt be equal');
  finally
    Node1.Free;
    Node2.Free;
    ValuedNode1.Free;
    ValuedNode2.Free;
  end;
end;

initialization
  RegisterTest(TestTPrimitiveEquivalenceChecker.Suite);

{$ENDIF}

end.
