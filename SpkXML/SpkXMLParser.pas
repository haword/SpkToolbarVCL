unit SpkXMLParser;

{$DEFINE SPKXMLPARSER}

interface

{TODO Uporz�dkowa� widoczno�� i wirtualno�� metod i w�asno�ci}

// Notatki: Stosuj� konsekwentnie case-insensitivity

uses
  SysUtils, Classes, ContNrs, Graphics, Math;

//todo: use LineEnding?
const CRLF=#13#10;

type // Rodzaj ga��zi XML
     TXMLNodeType = (xntNormal, xntControl, xntComment);

type // Forward dla klasy ga��zi XML
     TSpkXMLNode = class;

     TBinaryTreeNode = class;

     // Ga��� drzewa binarnych przeszukiwa�
     TBinaryTreeNode = class(TObject)
     private
     // Lewe poddrzewo
       FLeft,
     // Prawe poddrzewo
       FRight,
     // Rodzic
       FParent : TBinaryTreeNode;
     // Dane zawarte w w�le
       FData : array of TSpkXMLNode;
     // Wysoko�� poddrzewa
       FSubtreeSize : integer;
     protected
     // *** Metody dotycz�ce drzewa ***

     // Setter dla lewego poddrzewa
       procedure SetLeft(ANode : TBinaryTreeNode);
     // Setter dla prawego poddrzewa
       procedure SetRight(ANode : TBinaryTreeNode);

     // *** Metody dotycz�ce danych ***

     // Getter dla liczby danych zawartych w w�le
       function GetCount : integer;
     // Getter dla danych zawartych w w�le
       function GetData(index : integer) : TSpkXMLNode;
     public
     // Konstruktor
       constructor create;
     // Destruktor
       destructor Destroy; override;

     // *** Metody dotycz�ce drzewa ***

     // Wymuszenie od�wie�enia wysoko�ci poddrzewa
       procedure RefreshSubtreeSize;
     // Metoda powoduje odpi�cie od obecnego parenta (wywo�ywana tylko przez
     // niego)
       procedure DetachFromParent;
     // Metoda powoduje przypi�cie do nowego parenta (wywo�ywana przez nowego
     // parenta
       procedure AttachToParent(AParent : TBinaryTreeNode);
     // Metoda wywo�ywana przez jedno z dzieci w momencie, gdy jest ono
     // przepinane do innego drzewa
       procedure DetachChild(AChild : TBinaryTreeNode);

     // *** Metody dotycz�ce danych ***

     // Dodaje dane
       procedure Add(AData : TSpkXMLNode);
     // Usuwa dane z listy (nie zwalnia!)
       procedure Remove(AData : TSpkXMLNode);
     // Usuwa dane o zadanym indeksie (nie zwalnia!)
       procedure Delete(index : integer);
     // Usuwa wszystkie dane
       procedure Clear;

       property Data[index : integer] : TSpkXMLNode read GetData;

       property Left : TBinaryTreeNode read FLeft write SetLeft;
       property Right : TBinaryTreeNode read FRight write SetRight;
       property Parent : TBinaryTreeNode read FParent;
       property SubtreeSize : integer read FSubtreeSize;
       property Count : integer read GetCount;
     end;

     // Klasa przechowuj�ca pojedynczy parametr ga��zi XMLowej
     TSpkXMLParameter = class(TObject)
     private
     // Nazwa parametru
       FName,
     // Warto�� parametru
       FValue : string;
     protected
     // Getter dla w�asno�ci ValueAsInteger
       function GetValueAsInteger : integer;
     // Setter dla w�asno�ci ValueAsInteger
       procedure SetValueAsInteger(AValue : integer);
     // Getter dla w�asno�ci ValueAsExtended
       function GetValueAsExtended : extended;
     // Setter dla w�asno�ci ValueAsExtended
       procedure SetValueAsExtended(AValue : extended);
     // Getter dla w�asno�ci ValueAsColor
       function GetValueAsColor : TColor;
     // Setter dla w�asno�ci ValueAsColor
       procedure SetValueAsColor(AValue : TColor);
     // Getter dla w�asno�ci ValueAsBoolean
       function GetValueAsBoolean : boolean;
     // Setter dla w�asno�ci ValueAsBoolean
       procedure SetValueAsBoolean(AValue : boolean);
     public
     // Konstruktor
       constructor create; overload;
     // Konstruktor pozwalaj�cy nada� pocz�tkowe warto�ci parametrowi
       constructor create(AName : string; AValue : string); overload;
     // Destruktor
       destructor Destroy; override;

       property Name : string read FName write FName;
       property Value : string read FValue write FValue;
       property ValueAsInteger : integer read GetValueAsInteger write SetValueAsInteger;
       property ValueAsExtended : extended read GetValueAsExtended write SetValueAsExtended;
       property ValueAsColor : TColor read GetValueAsColor write SetValueAsColor;
       property ValueAsBoolean : boolean read GetValueAsBoolean write SetValueAsBoolean;
     end;

     // Lista parametr�w
     TSpkXMLParameters = class(TObject)
     private
     // Wewn�trzna lista na kt�rej przechowywane s� parametry ga��zi
       FList : TObjectList;
     protected
     // Getter dla w�asno�ci ParamByName (szuka parametru po jego nazwie)
       function GetParamByName(index : string; autocreate : boolean) : TSpkXMLParameter;
     // Getter dla w�asno�ci ParamByIndex (zwraca i-ty parametr)
       function GetParamByIndex(index : integer) : TSpkXMLParameter;
     // Zwraca liczb� parametr�w
       function GetCount : integer;
     public
     // Konstruktor
       constructor create;
     // Destruktor
       destructor Destroy; override;

     // Dodaje parametr na list�
       procedure Add(AParameter : TSpkXMLParameter);
     // Wstawia parametr na list� na zadane miejsce
       procedure Insert( AIndex : integer; AParameter : TSpkXMLParameter);
     // Usuwa parametr o podanym indeksie z listy
       procedure Delete(index : integer);
     // Usuwa zadany parametr z listy
       procedure Remove(AParameter : TSpkXMLParameter);
     // Zwraca indeks zadanego parametru
       function IndexOf(AParameter : TSpkXMLParameter) : integer;
     // Czy�ci list� parametr�w
       procedure Clear;

       property ParamByName[index : string; autocreate : boolean] : TSpkXMLParameter read GetParamByName; default;
       property ParamByIndex[index : integer] : TSpkXMLParameter read GetParamByIndex;

       property Count : integer read GetCount;
     end;

     TSpkBaseXmlNode = class;

     // Bazowa klasa dla ga��zi XMLowych, zapewniaj�ca przechowywanie, operacje
     // i wyszukiwanie podga��zi.
     TSpkBaseXmlNode = class(TObject)
     private
       FList : TObjectList;
       FTree : TBinaryTreeNode;
       FParent : TSpkBaseXmlNode;
     protected
     // *** Operacje na drzewie AVL ***
     // Dodaje do drzewa ga��� z zadan� TSpkXMLNode
       procedure TreeAdd(ANode : TSpkXMLNode);
     // Usuwa z drzewa ga��� z zadan� TSpkXMLNode
       procedure TreeDelete(ANode : TSpkXMLNode);
     // Szuka ga��zi drzewa
       function TreeFind(ANode : TSpkXMLNode) : TBinaryTreeNode;
     // Balansuje wszystkie w�z�y od zadanego do korzenia w��cznie.
       procedure Ballance(Leaf : TBinaryTreeNode);
     // Obraca w�ze� w lewo i zwraca w�ze�, kt�ry znalaz� si� w miejscu
     // obr�conego.
       function RotateLeft(Root : TBinaryTreeNode) : TBinaryTreeNode;
     // Obraca w�ze� w prawo i zwraca w�ze�, kt�ry znalaz� si� w miejscu
     // obr�conego
       function RotateRight(Root : TBinaryTreeNode) : TBinaryTreeNode;

       function GetNodeByIndex(index : integer) : TSpkXMLNode;
       function GetNodeByName(index : string; autocreate : boolean) : TSpkXMLNode;
       function GetCount : integer;
     public
     // Konstruktor
       constructor create; virtual;
     // Destruktor
       destructor Destroy; override;

     // Dodaje podga��� i umieszcza w odpowiednim miejscu w drzewie
       procedure Add(ANode : TSpkXMLNode);
     // Wstawia podga��� w podane miejsce (na drzewie ma to taki sam efekt
     // jak dodanie)
       procedure Insert(AIndex : integer; ANode : TSpkXMLNode);
     // Usuwa podga��� z listy i z drzewa, a nast�pnie zwalnia pami��
       procedure Delete(AIndex : integer);
     // Usuwa podga��� z listy i z drzewa, a nast�pnie zwalnia pami��
       procedure Remove(ANode : TSpkXMLNode);
     // Zwraca indeks podga��zi
       function IndexOf(ANode : TSpkXMLNode) : integer;
     // Usuwa wszystkie podga��zie
       procedure Clear; virtual;

     // Metoda powinna zosta� wywo�ana przed zmian� nazwy przez jedn� z podga��zi
       procedure BeforeChildChangeName(AChild : TSpkXmlNode);
     // Metoda powinna zosta� wywo�ana po zmianie nazwy przez jedn� z podga��zi
       procedure AfterChildChangeName(AChild : TSpkXMLNode);

       property NodeByIndex[index : integer] : TSpkXMLNode read GetNodeByIndex;
       property NodeByName[index : string; autocreate : boolean] : TSpkXMLNode read GetNodeByName; default;
       property Count : integer read GetCount;
       property Parent : TSpkBaseXmlNode read FParent write FParent;
     end;

     // Ga��� XMLa. Dzi�ki temu, �e dziedziczymy po TSpkBaseXMLNode mamy
     // zapewnion� obs�ug� podga��zi, trzeba tylko doda� parametry, nazw� i
     // tekst.
     TSpkXMLNode = class(TSpkBaseXMLNode)
     private
     // Nazwa ga��zi
       FName : string;
     // Tekst ga��zi
       FText : string;
     // Parametry ga��zi
       FParameters : TSpkXMLParameters;
     // Rodzaj ga��zi
       FNodeType : TXMLNodeType;
     protected
     // Setter dla w�asno�ci name (przed i po zmianie nazwy trzeba poinformowa�
     // parenta, by poprawnie dzia�a�o wyszukiwanie po nazwie
       procedure SetName(Value : string);
     // Getter dla TextAsInteger
       function GetTextAsInteger : integer;
     // Setter dla TextAsInteger
       procedure SetTextAsInteger(value : integer);
     // Getter dla TextAsExtended
       function GetTextAsExtended : extended;
     // Setter dla TextAsExtended
       procedure SetTextAsExtended(value : extended);
     // Getter dla TextAsColor
       function GetTextAsColor : TColor;
     // Setter dla TextAsColor
       procedure SetTextAsColor(value : TColor);
     // Getter dla TextAsBoolean
       function GetTextAsBoolean : boolean;
     // Setter dla TextAsBoolean
       procedure SetTextAsBoolean(value : boolean);
     public
     // Konstruktor
       constructor create(AName : string; ANodeType : TXMLNodeType); reintroduce;
     // Destruktor
       destructor Destroy; override;
     // Czy�ci ga��� (tekst, parametry, podga��zie)
       procedure Clear; override;

       property Name : string read FName write SetName;
       property Text : string read FText write FText;
       property TextAsInteger : integer read GetTextAsInteger write SetTextAsInteger;
       property TextAsExtended : extended read GetTextAsExtended write SetTextAsExtended;
       property TextAsColor : TColor read GetTextAsColor write SetTextAsColor;
       property TextAsBoolean : boolean read GetTextAsBoolean write SetTextAsBoolean;
       property Parameters : TSpkXMLParameters read FParameters;
       property NodeType : TXMLNodeType read FNodeType;
     end;

     // Dzi�ki temu, �e dziedziczymy po TSpkBaseXMLNode, mamy zapewnion� obs�ug�
     // podga��zi
     TSpkXMLParser = class(TSpkBaseXMLNode)
     private
     protected
     public
     // Konstruktor
       constructor create; override;
     // Destruktor
       destructor Destroy; override;
     // Przetwarza tekst z XMLem podany jako parametr
       procedure Parse(input : PChar);
     // Generuje XML na podstawie zawarto�ci komponentu
       function Generate(UseFormatting : boolean = true) : string;
     // Wczytuje plik XML z dysku
       procedure LoadFromFile(AFile : string);
     // Zapisuje plik XML na dysk
       procedure SaveToFile(AFile : string; UseFormatting : boolean = true);
     // Wczytuje plik XML ze strumienia
       procedure LoadFromStream(AStream : TStream);
     // Zapisuje plik XML do strumienia
       procedure SaveToStream(AStream : TStream; UseFormatting : boolean = true);
     end;

implementation

{ TBinaryTreeNode }

procedure TBinaryTreeNode.SetLeft(ANode : TBinaryTreeNode);

begin
// Odpinamy poprzedni� lew� ga��� (o ile istnia�a)
if FLeft<>nil then
   begin
   FLeft.DetachFromParent;
   FLeft:=nil;
   end;

// Przypinamy now� ga���
FLeft:=ANode;

// Aktualizujemy jej parenta
if FLeft<>nil then
   FLeft.AttachToParent(self);

// Od�wie�amy wysoko�� poddrzewa
RefreshSubtreeSize;
end;

procedure TBinaryTreeNode.SetRight(ANode : TBinaryTreeNode);

begin
// Odpinamy poprzedni� praw� ga��� (o ile istnia�a)
if FRight<>nil then
   begin
   FRight.DetachFromParent;
   FRight:=nil;
   end;

// Przypinamy now� ga���
FRight:=ANode;

// Aktualizujemy jej parnenta
if FRight<>nil then
   FRight.AttachToParent(self);

// Od�wie�amy wysoko�� poddrzewa
RefreshSubtreeSize;
end;

function TBinaryTreeNode.GetCount : integer;

begin
result:=length(FData);
end;

function TBinaryTreeNode.GetData(index : integer) : TSpkXMLNode;

begin
if (index<0) or (index>high(FData)) then
   raise exception.create('Nieprawid�owy indeks!');

result:=FData[index];
end;

constructor TBinaryTreeNode.create;

begin
inherited create;
FLeft:=nil;
FRight:=nil;
FParent:=nil;
setlength(FData,0);
FSubtreeSize:=0;
end;

destructor TBinaryTreeNode.destroy;

begin
// Odpinamy si� od parenta
if FParent<>nil then
   FParent.DetachChild(self);

// Zwalniamy poddrzewa
if FLeft<>nil then
   FLeft.free;
if FRight<>nil then
   FRight.free;

inherited destroy;
end;

procedure TBinaryTreeNode.RefreshSubtreeSize;

  function LeftSubtreeSize : integer;

  begin
  if FLeft=nil then result:=0 else result:=1+FLeft.SubTreeSize;
  end;

  function RightSubtreeSize : integer;

  begin
  if FRight=nil then result:=0 else result:=1+FRight.SubTreeSize;
  end;

begin
FSubtreeSize:=max(LeftSubtreeSize,RightSubtreeSize);
if Parent<>nil then
   Parent.RefreshSubtreeSize;
end;

procedure TBinaryTreeNode.DetachFromParent;

begin
// Zgodnie z za�o�eniami, metod� t� mo�e zawo�a� tylko obecny parent.
FParent:=nil;
end;

procedure TBinaryTreeNode.AttachToParent(AParent : TBinaryTreeNode);

begin
// Zgodnie z za�o�eniami, t� metod� wywo�uje nowy parent elementu. Element
// musi zadba� o to, by poinformowa� poprzedniego parenta o tym, �e jest on
// odpinany.
if AParent<>FParent then
   begin
   if FParent<>nil then
      FParent.DetachChild(self);

   FParent:=AParent;
   end;
end;

procedure TBinaryTreeNode.DetachChild(AChild : TBinaryTreeNode);

begin
// Zgodnie z za�o�eniami, metod� t� mo�e wywo�a� tylko jeden z podelement�w
// - lewy lub prawy, podczas zmiany parenta.
if AChild=FLeft then FLeft:=nil;
if AChild=FRight then FRight:=nil;

// Przeliczamy ponownie wysoko�� poddrzewa
RefreshSubtreeSize;
end;

procedure TBinaryTreeNode.Add(AData : TSpkXMLNode);

begin
{$B-}
if (length(FData)=0) or ((length(FData)>0) and (uppercase(FData[0].Name)=uppercase(AData.Name))) then
   begin
   setlength(FData,length(FData)+1);
   FData[high(FData)]:=AData;
   end else
       raise exception.create('Pojedyncza ga��� przechowuje dane o jednakowych nazwach!');
end;

procedure TBinaryTreeNode.Remove(AData : TSpkXMLNode);

var i : integer;

begin
i:=0;
{$B-}
while (i<=high(FData)) and (FData[i]<>AData) do
      inc(i);

if i<high(FData) then
   self.Delete(i);
end;

procedure TBinaryTreeNode.Delete(index : integer);

var i : integer;

begin
if (index<0) or (index>high(FData)) then
   raise exception.create('Nieprawid�owy indeks.');

if index<high(FData) then
   for i:=index to high(FData)-1 do
       FData[i]:=FData[i+1];

setlength(FData,length(FData)-1);
end;

procedure TBinaryTreeNode.Clear;

begin
setlength(FData,0);
end;

{ TSpkXMLParameter }

constructor TSpkXMLParameter.create;
begin
inherited create;
FName:='';
FValue:='';
end;

constructor TSpkXMLParameter.create(AName, AValue: string);
begin
inherited create;
FName:=AName;
FValue:=AValue;
end;

destructor TSpkXMLParameter.destroy;
begin
inherited destroy;
end;

function TSpkXMLParameter.GetValueAsBoolean: boolean;
begin
if (uppercase(FValue)='TRUE') or (uppercase(FValue)='T') or
   (uppercase(FValue)='YES') or (uppercase(FValue)='Y') then result:=true else
if (uppercase(FValue)='FALSE') or (uppercase(FValue)='F') or
   (uppercase(FValue)='NO') or (uppercase(FValue)='N') then result:=false else
   raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;

function TSpkXMLParameter.GetValueAsColor: TColor;

begin
try
result:=StrToInt(FValue);
except
raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;
end;

function TSpkXMLParameter.GetValueAsExtended: extended;
begin
try
result:=StrToFloat(FValue);
except
raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;
end;

function TSpkXMLParameter.GetValueAsInteger: integer;
begin
try
result:=StrToInt(FValue);
except
raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;
end;

procedure TSpkXMLParameter.SetValueAsBoolean(AValue: boolean);
begin
if AValue then FValue:='True' else FValue:='False';
end;

procedure TSpkXMLParameter.SetValueAsColor(AValue: TColor);
begin
FValue:=IntToStr(AValue);
end;

procedure TSpkXMLParameter.SetValueAsExtended(AValue: extended);
begin
FValue:=FloatToStr(AValue);
end;

procedure TSpkXMLParameter.SetValueAsInteger(AValue: integer);
begin
FValue:=IntToStr(AValue);
end;

{ TSpkXMLParameters }

procedure TSpkXMLParameters.Add(AParameter: TSpkXMLParameter);
begin
FList.add(AParameter);
end;

procedure TSpkXMLParameters.Insert(AIndex : integer; AParameter : TSpkXMLParameter);

begin
if (AIndex<0) or (AIndex>FList.count-1) then
   raise exception.create('Nieprawid�owy indeks.');

FList.Insert(AIndex, AParameter);
end;

procedure TSpkXMLParameters.Clear;
begin
FList.clear;
end;

constructor TSpkXMLParameters.create;
begin
inherited create;
FList:=TObjectList.create;
FList.OwnsObjects:=true;
end;

procedure TSpkXMLParameters.Delete(index: integer);
begin
if (index<0) or (index>FList.count-1) then
   raise exception.create('Nieprawid�owy indeks parametru.');

FList.delete(index);
end;

procedure TSpkXMLParameters.Remove(AParameter : TSpkXMLParameter);

begin
FList.Remove(AParameter);
end;

destructor TSpkXMLParameters.destroy;
begin
FList.Free;
inherited destroy;
end;

function TSpkXMLParameters.GetCount: integer;
begin
result:=FList.count;
end;

function TSpkXMLParameters.GetParamByIndex(index: integer): TSpkXMLParameter;
begin
if (index<0) or (index>Flist.count-1) then
   raise exception.create('Nieprawid�owy indeks elementu.');

result:=TSpkXMLParameter(FList[index]);
end;

function TSpkXMLParameters.GetParamByName(index: string;
  autocreate: boolean): TSpkXMLParameter;

var i : integer;
    AParameter : TSpkXMLParameter;

begin
// Szukamy elementu
i:=0;
while (i<=FList.count-1) and (uppercase(TSpkXMLParameter(FList[i]).Name)<>uppercase(index)) do inc(i);

if i<=FList.count-1 then
   result:=TSpkXMLParameter(FList[i]) else
   begin
   if autocreate then
      begin
      AParameter:=TSpkXMLParameter.create(index,'');
      FList.add(AParameter);
      result:=AParameter;
      end else
          result:=nil;
   end;
end;

function TSpkXMLParameters.IndexOf(AParameter: TSpkXMLParameter): integer;
begin
result:=FList.IndexOf(AParameter);
end;

{ TSpkBaseXMLNode }

procedure TSpkBaseXMLNode.TreeAdd(ANode : TSpkXMLNode);

var Tree, Parent : TBinaryTreeNode;

begin
// Szukam miejsca do dodania nowej ga��zi drzewa
if Ftree=nil then
   begin
   // Nie mamy czego szuka�, tworzymy korze�
   FTree:=TBinaryTreeNode.create;
   FTree.Add(ANode);

   // Nie ma potrzeby balansowania drzewa
   end else
       begin
       Tree:=FTree;
       Parent:=nil;
       {$B-}
       while (Tree<>nil) and (uppercase(Tree.Data[0].Name)<>uppercase(ANode.Name)) do
             begin
             Parent:=Tree;
             if uppercase(ANode.Name)<uppercase(Tree.Data[0].Name) then Tree:=Tree.Left else Tree:=Tree.Right;
             end;

       if Tree<>nil then
          begin
          // Znalaz�em ga��� z takim samym identyfikatorem
          Tree.Add(ANode);

          // Nie ma potrzeby balansowania drzewa, bo faktycznie nie zosta�a
          // dodana �adna ga���
          end else
              begin
              Tree:=TBinaryTreeNode.create;
              Tree.Add(ANode);

              if uppercase(ANode.Name)<uppercase(Parent.Data[0].Name) then
                 Parent.Left:=Tree else
                 Parent.Right:=Tree;

              // Zosta�a dodana nowa ga���, wi�c balansujemy drzewo (o ile jest
              // taka potrzeba)
              self.Ballance(Tree);
              end;
       end;
end;

procedure TSpkBaseXMLNode.TreeDelete(ANode : TSpkXMLNode);

  procedure InternalTreeDelete(DelNode : TBinaryTreeNode);

  var DelParent : TBinaryTreeNode;
      Successor : TBinaryTreeNode;
      SuccessorParent : TBinaryTreeNode;
      DeletingRoot : boolean;
      i : integer;

  begin
  // Najpierw sprawdzamy, czy b�dziemy usuwa� korze�. Je�li tak, po usuni�ciu
  // mo�e by� potrzebna aktualizacja korzenia.
  DeletingRoot:=DelNode=FTree;

  // Kilka przypadk�w.
  // 0. Mo�e elementu nie ma w drzewku?
  if DelNode=nil then
     raise exception.create('Takiego elementu nie ma w drzewie AVL!') else
  // 1. Je�li ga��� ta przechowuje wi�cej ni� tylko ten element, to usuwamy go
  //    z listy i ko�czymy dzia�anie.
  if DelNode.Count>1 then
     begin
     i:=0;
     while (i<DelNode.Count) and (DelNode.Data[i]<>ANode) do inc(i);

     DelNode.Delete(i);
     end else
  // 2. Je�li jest to li��, po prostu usuwamy go.
  if (DelNode.Left=nil) and (DelNode.Right=nil) then
     begin
     DelParent:=DelNode.Parent;

     // Odpinamy od parenta
     if DelParent<>nil then
        begin
        if DelParent.Left=DelNode then DelParent.Left:=nil;
        if DelParent.Right=DelNode then DelParent.Right:=nil;
        end;

     // Ga��� automatycznie odpina wszystkie swoje podga��zie, ale zak�adamy
     // tu, �e jest to li��.
     DelNode.free;

     // Je�li zachodzi taka potrzeba, balansujemy drzewo od ojca usuwanego
     // elementu
     if DelParent<>nil then
        self.Ballance(DelParent);

     // Je�li usuwali�my root, ustawiamy go na nil (bo by� to jedyny element)
     if DeletingRoot then FTree:=nil;
     end else
  // 3. Je�eli element ma tylko jedno dziecko, usuwamy je, poprawiamy powi�zania
  //    i balansujemy drzewo
  if (DelNode.Left=nil) xor (DelNode.Right=nil) then
     begin
     DelParent:=DelNode.Parent;

     if DelParent=nil then
        begin
        // Usuwamy korze�
        if DelNode.Left<>nil then
           begin
           FTree:=DelNode.Left;
           // Mechanizmy drzewa odepn� automatycznie ga��� od DelNode, dzi�ki
           // czemu nie zostanie usuni�te ca�e poddrzewo
           end else
        if DelNode.Right<>nil then
           begin
           FTree:=DelNode.Right;
           // Mechanizmy drzewa odepn� automatycznie ga��� od DelNode, dzi�ki
           // czemu nie zostanie usuni�te ca�e poddrzewo
           end;

        // Usuwamy element
        DelNode.Free;

        // Nie ma potrzeby balansowa� drzewa, z za�o�enie poddrzewo jest
        // zbalansowane.
        end else
     if DelParent<>nil then
        begin
        // Cztery przypadki
        if DelParent.Left=DelNode then
           begin
           if DelNode.Left<>nil then
              begin
              DelParent.Left:=DelNode.Left;
              end else
           if DelNode.Right<>nil then
              begin
              DelParent.Left:=DelNode.Right;
              end;
           end else
        if DelParent.Right=DelNode then
           begin
           if DelNode.Left<>nil then
              begin
              DelParent.Right:=DelNode.Left;
              end else
           if DelNode.Right<>nil then
              begin
              DelParent.Right:=DelNode.Right;
              end;
           end;

        DelNode.Free;

        self.Ballance(DelParent);
        end;
     end else
  // 4. Zamieniamy zawarto�� "usuwanego" poddrzewa z jego nast�pnikiem, kt�ry
  //    ma tylko jedno dziecko, a nast�pnie usuwamy nast�pnik.
  if (DelNode.Left<>nil) and (DelNode.Right<>nil) then
     begin
     // Szukamy nast�pnika
     Successor:=DelNode.Right;
     while Successor.Left<>nil do Successor:=Successor.Left;
     SuccessorParent:=Successor.Parent;

     // Przepinamy dane z nast�pnika do "usuwanego" elementu
     DelNode.Clear;
     if Successor.Count>0 then
        for i:=0 to Successor.Count-1 do
            begin
            DelNode.Add(Successor.Data[i]);
            end;

     // Teraz usuwamy nast�pnik
     InternalTreeDelete(Successor);

     // Od�wie�amy dane dotycz�ce poddrzew
     self.Ballance(SuccessorParent);
     end;
  end;

begin
InternalTreeDelete(self.TreeFind(ANode));
end;

function TSpkBaseXMLNode.TreeFind(ANode : TSpkXMLNode) : TBinaryTreeNode;

var Tree : TBinaryTreeNode;
    i : integer;

begin
Tree:=FTree;

while (Tree<>nil) and (uppercase(Tree.Data[0].Name)<>uppercase(ANode.Name)) do
      begin
      if uppercase(ANode.Name)<uppercase(Tree.Data[0].Name) then
         Tree:=Tree.Left else
         Tree:=Tree.Right;
      end;

if Tree<>nil then
   begin
   i:=0;
   {$B-}
   while (i<Tree.Count) and (Tree.Data[i]<>ANode) do inc(i);
   if i=Tree.Count then result:=nil else result:=Tree;
   end else result:=nil;
end;

procedure TSpkBaseXMLNode.Ballance(Leaf : TBinaryTreeNode);

  function CalcLeft(Node : TBinaryTreeNode) : integer;

  begin
  if Node.Left=nil then result:=0 else result:=1+Node.Left.SubtreeSize;
  end;

  function CalcRight(Node : TBinaryTreeNode) : integer;

  begin
  if Node.Right=nil then result:=0 else result:=1+Node.Right.SubtreeSize;
  end;

begin
if Leaf<>nil then
   begin
   while CalcLeft(Leaf)-CalcRight(Leaf)>=2 do
         Leaf:=RotateRight(Leaf);
   while CalcRight(Leaf)-CalcLeft(Leaf)>=2 do
         Leaf:=RotateLeft(Leaf);
   self.Ballance(Leaf.Parent);
   end;
end;

{  RootParent
      \ /                      \ /
       1  Root                  2
      / \                      / \
     A   2  RotNode    ~>     1   C
        / \                  / \
       B   C                A   B
}
function TSpkBaseXMLNode.RotateLeft(Root : TBinaryTreeNode) : TBinaryTreeNode;

var RootParent : TBinaryTreeNode;
    RotNode : TBinaryTreeNode;

begin
result:=nil;
if Root.Right=nil then
   raise exception.create('Prawa podga��� jest pusta!');

RootParent:=Root.Parent;
RotNode:=Root.Right;

if RootParent<>nil then
   begin
   if Root=RootParent.Left then
      begin
      Root.Right:=RotNode.Left;
      RotNode.Left:=Root;
      RootParent.Left:=RotNode;

      result:=RotNode;
      end else
   if Root=RootParent.Right then
      begin
      Root.Right:=RotNode.Left;
      RotNode.Left:=Root;
      RootParent.Right:=RotNode;

      result:=RotNode;
      end;
   end else
if RootParent=nil then
   begin
   // Obracamy korze�
   Root.Right:=RotNode.Left;
   RotNode.Left:=Root;
   FTree:=RotNode;

   result:=RotNode;
   end;
end;

{      RootParent
          \ /              \ /
     Root  1                2
          / \              / \
 RotNode 2   C     ~>     A   1
        / \                  / \
       A   B                B   C
}
function TSpkBaseXMLNode.RotateRight(Root : TBinaryTreeNode) : TBinaryTreeNode;

var RootParent : TBinaryTreeNode;
    RotNode : TBinaryTreeNode;

begin
result:=nil;
if Root.Left=nil then
   raise exception.create('Lewa podga��� jest pusta!');

RootParent:=Root.Parent;
RotNode:=Root.Left;

if RootParent<>nil then
   begin
   if Root=RootParent.Left then
      begin
      Root.Left:=RotNode.Right;
      RotNode.Right:=Root;
      RootParent.Left:=RotNode;

      result:=RotNode;
      end else
   if Root=RootParent.Right then
      begin
      Root.Left:=RotNode.Right;
      RotNode.Right:=Root;
      RootParent.Right:=RotNode;

      result:=RotNode;
      end;
   end else
if RootParent=nil then
   begin
   // Obracamy korze�
   Root.Left:=RotNode.Right;
   RotNode.Right:=Root;
   FTree:=RotNode;

   result:=RotNode;
   end;
end;

function TSpkBaseXMLNode.GetNodeByIndex(index : integer) : TSpkXMLNode;

begin
if (index<0) or (index>FList.count-1) then
   raise exception.create('Nieprawid�owy indeks!');

result:=TSpkXMLNode(FList[index]);
end;

function TSpkBaseXMLNode.GetNodeByName(index : string; autocreate : boolean) : TSpkXMLNode;

var Tree : TBinaryTreeNode;
    XmlNode : TSpkXMLNode;

begin
Tree:=FTree;
{$B-}
while (Tree<>nil) and (uppercase(Tree.Data[0].Name)<>uppercase(index)) do
      begin
      if uppercase(index)<uppercase(Tree.Data[0].Name) then
         Tree:=Tree.Left else
         Tree:=Tree.Right;
      end;

if Tree<>nil then result:=Tree.Data[0] else
   begin
   if not(autocreate) then
      result:=nil else
      begin
      XmlNode:=TSpkXMLNode.create(index,xntNormal);
      TreeAdd(XmlNode);
      FList.add(XmlNode);
      result:=XmlNode;
      end;
   end;
end;

function TSpkBaseXMLNode.GetCount : integer;

begin
result:=FList.Count;
end;

constructor TSpkBaseXMLNode.create;

begin
inherited create;
FList:=TObjectList.create;
FList.OwnsObjects:=true;
FTree:=nil;
FParent:=nil;
end;

destructor TSpkBaseXMLNode.destroy;

begin
// Drzewko zadba o rekurencyjne wyczyszczenie
FTree.free;

// Lista zadba o zwolnienie podga��zi
FList.free;

inherited destroy;
end;

procedure TSpkBaseXMLNode.Add(ANode : TSpkXMLNode);

begin
if ANode = self then
   raise exception.create('Nie mog� doda� siebie do w�asnej listy!');
if ANode.NodeType=xntNormal then
   TreeAdd(ANode);
FList.add(ANode);
ANode.Parent:=self;
end;

procedure TSpkBaseXMLNode.Insert(AIndex : integer; ANode : TSpkXMLNode);

begin
if (AIndex<0) or (AIndex>FList.count-1) then
   raise exception.create('Nieprawid�owy indeks!');

FList.Insert(AIndex, ANode);
TreeAdd(ANode);
ANode.Parent:=self;
end;

procedure TSpkBaseXMLNode.Delete(AIndex : integer);

begin
if (AIndex<0) or (AIndex>FList.count-1) then
   raise exception.create('Nieprawid�owy indeks!');

TreeDelete(TSpkXMLNode(FList[AIndex]));

// Poniewa� FList.OwnsObjects, automatycznie zwolni usuwany element.
FList.delete(AIndex);
end;

procedure TSpkBaseXMLNode.Remove(ANode : TSpkXMLNode);

begin
TreeDelete(ANode);

// Poniewa� FList.OwnsObjects, automatycznie zwolni usuwany element.
FList.Remove(ANode);
end;

function TSpkBaseXMLNode.IndexOf(ANode : TSpkXMLNode) : integer;

begin
result:=FList.IndexOf(ANode);
end;

procedure TSpkBaseXMLNode.Clear;

begin
FTree.Free;
FTree:=nil;

// Poniewa� FList.OwnsObjects, automatycznie zwolni usuwany element.
FList.clear;
end;

procedure TSpkBaseXMLNode.BeforeChildChangeName(AChild : TSpkXmlNode);

begin
TreeDelete(AChild);
end;

procedure TSpkBaseXMLNode.AfterChildChangeName(AChild : TSpkXMLNode);

begin
TreeAdd(AChild);
end;

{ TSpkXMLNode }

procedure TSpkXMLNode.SetName(Value : string);

begin
if Parent<>nil then
   Parent.BeforeChildChangeName(self);

FName:=Value;

if Parent<>nil then
   Parent.AfterChildChangeName(self);
end;

function TSpkXMLNode.GetTextAsInteger : integer;

begin
try
result:=StrToInt(FText);
except
raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;
end;

procedure TSpkXMLNode.SetTextAsInteger(value : integer);

begin
FText:=IntToStr(value);
end;

function TSpkXMLNode.GetTextAsExtended : extended;

begin
try
result:=StrToFloat(FText);
except
raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;
end;

procedure TSpkXMLNode.SetTextAsExtended(value : extended);

begin
FText:=FloatToStr(value);
end;

function TSpkXMLNode.GetTextAsColor : TColor;

begin
try
result:=StrToInt(FText);
except
raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;
end;

procedure TSpkXMLNode.SetTextAsColor(value : TColor);

begin
FText:=IntToStr(value);
end;

function TSpkXMLNode.GetTextAsBoolean : boolean;

begin
if (uppercase(FText)='TRUE') or (uppercase(FText)='T') or
   (uppercase(FText)='YES') or (uppercase(FText)='Y') then result:=true else
if (uppercase(FText)='FALSE') or (uppercase(FText)='F') or
   (uppercase(FText)='NO') or (uppercase(FText)='N') then result:=false else
   raise exception.create('Nie mog� przekonwertowa� warto�ci.');
end;

procedure TSpkXMLNode.SetTextAsBoolean(value : boolean);

begin
if value then FText:='True' else FText:='False';
end;

constructor TSpkXMLNode.create(AName : string; ANodeType : TXMLNodeType);

begin
inherited create;
FName:=AName;
FText:='';
FNodeType:=ANodeType;
FParameters:=TSpkXMLParameters.create;
end;

destructor TSpkXMLNode.destroy;

begin
FParameters.free;
inherited destroy;
end;

procedure TSpkXMLNode.Clear;

begin
inherited Clear;
FParameters.Clear;
FText:='';
end;

{ TSpkXMLParser }

constructor TSpkXMLParser.create;

begin
inherited create;
end;

destructor TSpkXMLParser.destroy;

begin
inherited destroy;
end;

procedure TSpkXMLParser.Parse(input : PChar);

type // Operacja, kt�r� aktualnie wykonuje parser.
     TParseOperation = (poNodes,           //< Przetwarzanie (pod)ga��zi
                        poTagInterior,     //< Przetwarzanie wn�trza zwyk�ego tagu (< > lub < />)
                        poTagText,         //< Tekst taga, kt�ry przetwarzamy
                        poControlInterior, //< Przetwarzanie kontrolnego taga (<? ?>)
                        poCommentInterior, //< Przetwarzanie komentarza (<!-- -->)
                        poClosingInterior  //< Przetwarzanie taga domykaj�cego.
                       );

var // Stos przetwarzanych ga��zi (niejawna rekurencja)
    NodeStack : TObjectStack;
    // Aktualna operacja. Podczas wychodzenia z operacji przetwarzaj�cych
    // tagi, domy�lnymi operacjami s� poSubNodes b�d� poOuter.
    CurrentOperation : TParseOperation;
    // Wska�nik na pocz�tek tokena
    TokenStart : PChar;
    // Przetwarzana ga��� XMLa
    Node : TSpkXMLNode;
    // Pomocnicze ci�gi znak�w
    s,s1 : string;
    // Pozycja w pliku - linia i znak
    ParseLine, ParseChar : integer;

  // Funkcja inkrementuje wska�nik wej�cia, pilnuj�c jednocze�nie, by uaktualni�
  // pozycj� w pliku
  procedure increment(var input : PChar; count : integer = 1);

  var i : integer;

  begin
  for i:=1 to count do
      begin
      if input^=#10 then
         begin
         inc(ParseLine);
         ParseChar:=1;
         end else
      if input^<>#13 then
         begin
         inc(ParseChar);
         end;
      inc(input);
      end;
  end;

  // Funkcja przetwarza tekst (wraz z <![CDATA[ ... ]]>) a� do napotkanego
  // delimitera. Dodatkowo zamienia encje na zwyk�e znaki.
  // Niestety, natura poni�szej funkcji powoduje, �e musz� dokleja� znaki
  // do ci�gu, trac�c na wydajno�ci.
  // DoTrim powoduje, �e wycinane s� pocz�tkowe i ko�cowe bia�e znaki (chyba,
  // �e zosta�y wpisane jako encje albo w sekcji CDATA)
  function ParseText(var input : PChar; TextDelimiter : char; DoTrim : boolean = false) : string;

  var Finish : boolean;
      Entity : string;
      i : integer;
      WhiteChars : string;

    // Funkcja robi dok�adnie to, na co wygl�da ;]
    function HexToInt(s : string) : integer;

    var i : integer;

    begin
    result:=0;
    for i:=1 to length(s) do
        begin
        result:=result*16;
        if s[i] in ['0'..'9'] then result:=result+ord(s[i])-ord('0') else
           if UpCase(s[i]) in ['A'..'F'] then result:=result+ord(s[i])-ord('A')+10 else
              raise exception.create('Nieprawid�owa liczba heksadecymalna!');
        end;
    end;

  begin
  result:='';

  // Wycinamy pocz�tkowe bia�e znaki
  if DoTrim then
     while input^ in [#32,#9,#13,#10] do increment(input);

  while (input^<>TextDelimiter) or ((input^='<') and (StrLComp(input,'<![CDATA[',9)=0)) do
        begin
        {$B-}

        // Nie mo�e wyst�pi� tu koniec pliku
        if input^=#0 then
           raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku.') else

        // Je�li napotkali�my nawias k�towy, mo�e to by� sekcja CDATA
        if (input^='<') and (StrLComp(input,'<![CDATA[',9)=0) then
           begin
           // Wczytujemy blok CDATA a� do znacznika zamkni�cia "]]>"
           // Pomijamy tag rozpoczynaj�cy CDATA
           increment(input,9);

           Finish:=false;
           repeat
           {$B-}
           if input^=#0 then
              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku.');
           if (input^=']') and (StrLComp(input,']]>',3)=0) then Finish:=true else
              begin
              result:=result+input^;
              increment(input);
              end;
           until Finish;

           // Pomijamy tag zamykaj�cy CDATA
           increment(input,3);
           end else

        // Obs�uga encji - np. &nbsp;
        if input^='&' then
           begin
           // Encja
           // Pomijamy znak ampersanda
           increment(input);

           Entity:='';
           while input^<>';' do
                 begin
                 if input^=#0 then
                    raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku - nie doko�czona encja.');
                 Entity:=Entity+input^;
                 increment(input);
                 end;

           // Pomijamy znak �rednika
           increment(input);

           // Analizujemy encj�
           Entity:=uppercase(entity);
           if Entity='AMP' then result:=result+'&' else
           if Entity='LT' then result:=result+'<' else
           if Entity='GT' then result:=result+'>' else
           if Entity='QUOT' then result:=result+'"' else
           if Entity='NBSP' then result:=result+' ' else
           if copy(Entity,1,2)='#x' then
              begin
              // Kod ASCII zapisany heksadecymalnie
              i:=HexToInt(copy(Entity,2,length(Entity)-1));
              if not(i in [0..255]) then
                 raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owa warto�� heksadecymalna encji (dopuszczalne: 0..255)');
              result:=result+chr(i);
              end else
           if Entity[1]='#' then
              begin
              i:=StrToInt(copy(Entity,2,length(Entity)-1));
              if not(i in [0..255]) then
                 raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owa warto�� dziesi�tna encji (dopuszczalne: 0..255)');
              result:=result+chr(i);
              end else
                  raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owa (nie obs�ugiwana) encja!');
           end else
        if (DoTrim) and (input^ in [#32,#9,#10,#13]) then
           begin
           // Zbieramy bia�e znaki a� do pierwszego niebia�ego; je�eli b�dzie
           // nim delimiter, bia�a sekwencja zostanie pomini�ta.
           WhiteChars:='';
           repeat
           WhiteChars:=input^;
           increment(input);
           until not(input^ in [#32,#9,#10,#13]);

           // Sprawdzamy, czy doda� sekwencj� bia�ych znak�w (ostro�nie z CDATA!)
           if (input^<>TextDelimiter) or ((input^='<') and (StrLComp(input,'<![CDATA[',9)=0)) then
              result:=result+WhiteChars;
           end else
        // Zwyk�y znak (nie b�d�cy delimiterem!)
        if input^<>TextDelimiter then
           begin
           result:=result+input^;
           increment(input);
           end;
        end;
  end;

begin
// Czy�cimy wszystkie ga��zie
self.Clear;

// Na wszelki wypadek...
if input^=#0 then exit;

// Zerujemy parsowan� pozycj�
ParseLine:=1;
ParseChar:=1;

// Inicjujemy stos ga��zi
NodeStack:=TObjectStack.Create;
CurrentOperation:=poNodes;

try

  while input^<>#0 do
  case CurrentOperation of
       poNodes : begin
                 // Pomijamy bia�e znaki
                 while input^ in [#32,#9,#10,#13] do increment(input);

                 // Wej�cie mo�e si� tu ko�czy� tylko wtedy, gdy jeste�my
                 // maksymalnie na zewn�trz
                 if (input^=#0) and (NodeStack.count>0) then
                    raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku.');

                 if (input^<>#0) and (input^<>'<') then
                    raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owy znak podczas przetwarzania pliku.');

                 if input^<>#0 then
                    if StrLComp(input,'<?',2)=0 then
                       CurrentOperation:=poControlInterior else
                    if StrLComp(input,'<!--',4)=0 then
                       CurrentOperation:=poCommentInterior else
                    if StrLComp(input,'</',2)=0 then
                       CurrentOperation:=poClosingInterior else
                    if StrLComp(input,'<',1)=0 then
                       CurrentOperation:=poTagInterior else
                       raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owy znak podczas przetwarzania pliku.');
                 end;

       poTagInterior,
       poControlInterior : begin
                           Node:=nil;
                           try

                           if CurrentOperation=poTagInterior then
                              begin
                              Node:=TSpkXMLNode.create('',xntNormal);

                              // Pomijamy znak otwarcia taga
                              increment(input);
                              end else
                                  begin
                                  Node:=TSpkXMLNode.create('',xntControl);

                                  // Pomijamy znaki otwarcia taga
                                  increment(input,2);
                                  end;

                           // Plik nie mo�e si� tu ko�czy�
                           if input^=#0 then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                           // Oczekujemy nazwy taga, kt�ra jest postaci
                           // [a-zA-Z]([a-zA-Z0-9_]|([\-:][a-zA-Z0-9_]))*
                           if not(input^ in ['a'..'z','A'..'Z']) then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owa nazwa taga!');

                           TokenStart:=input;
                           repeat
                           increment(input);
                           if input^ in ['-',':'] then
                              begin
                              increment(input);
                              if not(input^ in ['a'..'z','A'..'Z','0'..'9','_']) then
                                 raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owa nazwa taga!');
                              increment(input);
                              end;
                           until not(input^ in ['a'..'z','A'..'Z','0'..'9','_']);

                           setlength(s,integer(input)-integer(TokenStart));
                           StrLCopy(PChar(s),TokenStart,integer(input)-integer(TokenStart));
                           Node.Name:=s;

                           // Plik nie mo�e si� tu ko�czy�.
                           if input^=#0 then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                           // Teraz b�dziemy wczytywa� parametry (o ile takowe s�).
                           repeat
                           // Wymagamy bia�ego znaku przed ka�dym parametrem.
                           if input^ in [#32,#9,#10,#13] then
                              begin
                              // Zjadamy bia�e znaki
                              while input^ in [#32,#9,#10,#13] do increment(input);

                              // Plik nie mo�e si� tu ko�czy�.
                              if input^=#0 then
                                 raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                              // Je�eli po bia�ych znakach jest litera,
                              // zaczynamy wczytywa� parametr
                              if input^ in ['a'..'z','A'..'Z'] then
                                 begin
                                 // Przetwarzamy parametr
                                 TokenStart:=input;

                                 repeat
                                 increment(input)
                                 until not(input^ in ['a'..'z','A'..'Z','0'..'9','_']);

                                 setlength(s,integer(input)-integer(TokenStart));
                                 StrLCopy(PChar(s),TokenStart,integer(input)-integer(TokenStart));

                                 // Pomijamy bia�e znaki
                                 while input^ in [#32,#9,#13,#10] do increment(input);

                                 // Plik nie mo�e si� tu ko�czy�
                                 if input^=#0 then
                                    raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                                 // Oczekujemy znaku '='
                                 if input^<>'=' then
                                    raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Oczekiwany znak r�wno�ci (prawdopodobnie nieprawid�owa nazwa parametru)');

                                 increment(input);

                                 // Pomijamy bia�e znaki
                                 while input^ in [#32,#9,#13,#10] do increment(input);

                                 // Plik nie mo�e si� tu ko�czy�
                                 if input^=#0 then
                                    raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                                 // Oczekujemy ' lub "
                                 if input^='''' then
                                    begin
                                    // Pomijamy znak apostrofu
                                    increment(input);
                                    s1:=ParseText(input,'''',false);
                                    // Pomijamy ko�cz�cy znak apostrofu
                                    increment(input);
                                    end else
                                 if input^='"' then
                                    begin
                                    // Pomijamy znak cudzys�owu
                                    increment(input);
                                    s1:=ParseText(input,'"',false);
                                    // Pomijamy ko�cz�cy znak cudzys�owu
                                    increment(input);
                                    end else
                                    raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owy znak, oczekiwano '' lub "');

                                 // Dodajemy parametr o nazwie s i zawarto�ci s1
                                 Node.Parameters[s,true].Value:=s1;
                                 end;
                              end;

                           // P�tla ko�czy si�, gdy na wej�ciu nie ma ju�
                           // bia�ego znaku, kt�ry jest wymagany przed i
                           // pomi�dzy parametrami. Sekwencja bia�ych znak�w
                           // po ostatnim parametrze zostanie pomini�ta wewn�trz
                           // p�tli.
                           until not(input^ in [#32,#9,#10,#13]);

                           // Plik nie mo�e si� tu ko�czy�.
                           if input^=#0 then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                           if CurrentOperation=poControlInterior then
                              begin
                              if StrLComp(input,'?>',2)<>0 then
                                 raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owe domkni�cie taga kontrolnego (powinno by�: ?>)');

                              // Pomijamy znaki zamkni�cia taga kontrolnego
                              increment(input,2);

                              if NodeStack.count>0 then
                                 TSpkXMLNode(NodeStack.Peek).Add(Node) else
                                 Self.Add(Node);

                              CurrentOperation:=poNodes;
                              end else
                           if CurrentOperation=poTagInterior then
                              begin
                              if StrLComp(input,'/>',2)=0 then
                                 begin
                                 // Pomijamy znaki zamkni�cia taga
                                 increment(input,2);

                                 if NodeStack.count>0 then
                                    TSpkXMLNode(NodeStack.Peek).add(Node) else
                                    Self.add(Node);

                                 CurrentOperation:=poNodes;
                                 end else
                              if StrLComp(input,'>',1)=0 then
                                 begin
                                 // Pomijamy znak zamkni�cia taga
                                 increment(input);

                                 NodeStack.Push(Node);

                                 CurrentOperation:=poTagText;
                                 end else
                                     raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owe domkni�cie taga XML (powinno by�: > lub />)');
                              end;

                           except
                           // Je�li co� p�jdzie nie tak, ga��� wisi w pami�ci i
                           // nie jest wrzucona na stos, trzeba j� zwolni�.

                           // Notatka jest taka, �e wszystkie wyj�tki, kt�re
                           // mog� si� pojawi�, s� *przed* wrzuceniem taga na
                           // stos lub do ga��zi na szczycie stosu.
                           if Node<>nil then Node.Free;
                           raise;
                           end;

                           end;

       poCommentInterior : begin
                           Node:=nil;

                           try

                           Node:=TSpkXMLNode.create('',xntComment);

                           // Pomijamy znaki otwarcia taga
                           increment(input,4);

                           // Wczytujemy komentarz
                           TokenStart:=input;
                           repeat
                             repeat
                             increment(input);
                             if input^=#0 then
                                raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');
                             until input^='-';
                           until StrLComp(input,'-->',3)=0;

                           setlength(s,integer(input)-integer(TokenStart));
                           StrLCopy(PChar(s),TokenStart,integer(input)-integer(TokenStart));
                           Node.Text:=s;

                           // Pomijamy znaki zako�czenia komentarza
                           increment(input,3);

                           if NodeStack.count>0 then
                              TSpkXMLNode(NodeStack.Peek).add(Node) else
                              Self.add(Node);

                           except
                           // Zarz�dzanie pami�ci� - zobacz poprzedni przypadek
                           if Node<>nil then Node.free;
                           raise
                           end;

                           CurrentOperation:=poNodes;
                           end;

       poClosingInterior : begin
                           // Pomijamy znaki otwieraj�ce zamykaj�cy tag
                           increment(input,2);

                           // Plik nie mo�e si� tu ko�czy�
                           if input^=#0 then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                           // Wczytujemy nazw� zamykanego taga postaci
                           // [a-zA-Z]([a-zA-Z0-9_]|([\-:][a-zA-Z0-9_]))*
                           if not(input^ in ['a'..'z','A'..'Z']) then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owa nazwa taga!');

                           TokenStart:=input;
                           repeat
                           increment(input);
                           if input^ in ['-',':'] then
                              begin
                              increment(input);
                              if not(input^ in ['a'..'z','A'..'Z','0'..'9','_']) then
                                 raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieprawid�owa nazwa taga!');
                              increment(input);
                              end;
                           until not(input^ in ['a'..'z','A'..'Z','0'..'9','_']);

                           setlength(s,integer(input)-integer(TokenStart));
                           StrLCopy(PChar(s),TokenStart,integer(input)-integer(TokenStart));

                           // Pomijamy zb�dne znaki bia�e
                           while input^ in [#32,#9,#10,#13] do increment(input);

                           // Plik nie mo�e si� tu ko�czy�
                           if input^=#0 then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku!');

                           // Oczekujemy znaku '>'
                           if input^<>'>' then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Oczekiwany znak zamkni�cia taga (>)');

                           // Pomijamy znak zamkni�cia taga
                           increment(input);

                           // Sprawdzamy, czy uppercase nazwa taga na stosie i
                           // wczytana pasuj� do siebie
                           if NodeStack.Count=0 then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Brakuje taga otwieraj�cego do zamykaj�cego!');

                           if uppercase(s)<>uppercase(TSpkXMLNode(NodeStack.Peek).Name) then
                              raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Tag zamykaj�cy ('+s+') nie pasuje do taga otwieraj�cego ('+TSpkXMLNode(NodeStack.Peek).Name+') !');

                           // Wszystko OK, zdejmujemy tag ze stosu i dodajemy go do taga pod nim
                           Node:=TSpkXMLNode(NodeStack.Pop);

                           if NodeStack.count>0 then
                              TSpkXMLNode(NodeStack.Peek).add(Node) else
                              Self.add(Node);

                           CurrentOperation:=poNodes;
                           end;

       poTagText : begin
                   // Wczytujemy tekst i przypisujemy go do taga znajduj�cego
                   // si� na szczycie stosu
                   s:=ParseText(input,'<',true);

                   if NodeStack.Count=0 then
                      raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Tekst mo�e wyst�powa� tylko wewn�trz tag�w!');

                   TSpkXMLNode(NodeStack.Peek).Text:=s;

                   CurrentOperation:=poNodes;
                   end;
  end;

  // Je�li na stosie pozosta�y jakie� ga��zie - oznacza to b��d (nie zosta�y
  // domkni�te)

  if NodeStack.Count>0 then
     raise exception.create('B��d w sk�adni XML (linia '+IntToStr(ParseLine)+', znak '+IntToStr(ParseChar)+') : Nieoczekiwany koniec pliku (istniej� nie domkni�te tagi, pierwszy z nich: '+TSpkXMLNode(NodeStack.Peek).Name+')');

  // Wszystko w porz�dku, XML zosta� wczytany.
finally

  // Czy�cimy nie przetworzone ga��zie
  while NodeStack.Count>0 do
        NodeStack.Pop.Free;
  NodeStack.Free;

end;

end;

function TSpkXMLParser.Generate(UseFormatting : boolean) : string;

  function InternalGenerate(RootNode : TSpkXMLNode; indent : integer; UseFormatting : boolean) : string;

  var i : integer;

    function MkIndent(i : integer) : string;

    begin
    result:='';
    if indent<=0 then exit;
    setlength(result,i);
    if i>0 then
       FillChar(result[1],i,32);
    end;

    function MkText(AText : string; CheckWhitespace : boolean = false) : string;

    var s : string;
        prefix,postfix : string;

    begin
    s:=AText;
    s:=StringReplace(s,'&','&amp;',[rfReplaceAll]);
    s:=StringReplace(s,'<','&lt;',[rfReplaceAll]);
    s:=StringReplace(s,'>','&gt;',[rfReplaceAll]);
    s:=StringReplace(s,'"','&quot;',[rfReplaceAll]);
    s:=StringReplace(s,'''','&#39;',[rfReplaceAll]);

    prefix:='';
    postfix:='';

    if CheckWhitespace then
       begin
       // Je�li pierwszy znak jest bia�y, zamie� go na encj�
       if s[1]=#32 then
          begin
          System.delete(s,1,1);
          prefix:='&#32;';
          end else
       if s[1]=#9 then
          begin
          System.delete(s,1,1);
          prefix:='&#9;';
          end else
       if s[1]=#10 then
          begin
          System.delete(s,1,1);
          prefix:='&#10;';
          {$B-}
          if (length(s)>0) and (s[1]=#13) then
             begin
             System.delete(s,1,1);
             prefix:=prefix+'&#13;';
             end;
          end else
       if s[1]=#13 then
          begin
          System.delete(s,1,1);
          prefix:='&#13;';
          {$B-}
          if (length(s)>0) and (s[1]=#10) then
             begin
             System.delete(s,1,1);
             prefix:=prefix+'&#10;';
             end;
          end;

       // Je�li ostatni znak jest bia�y, zamie� go na encj�
       if length(s)>0 then
          begin
          if s[length(s)]=#32 then
             begin
             System.delete(s,length(s),1);
             postfix:='&#32;';
             end else
          if s[length(s)]=#9 then
             begin
             System.delete(s,length(s),1);
             postfix:='&#32;';
             end else
          if s[length(s)]=#10 then
             begin
             System.Delete(s,length(s),1);
             postfix:='&#10;';
             if (length(s)>0) and (s[length(s)]=#13) then
                begin
                System.Delete(s,length(s),1);
                postfix:='&#13;'+postfix;
                end;
             end else
          if s[length(s)]=#13 then
             begin
             System.Delete(s,length(s),1);
             postfix:='&#13;';
             if (length(s)>0) and (s[length(s)]=#10) then
                begin
                System.Delete(s,length(s),1);
                postfix:='&#10;'+postfix;
                end;
             end;
          end;
       end;
    result:=prefix+s+postfix;
    end;

  begin
  result:='';
  if RootNode=nil then
     begin
     if FList.count>0 then
        for i:=0 to FList.count-1 do
            result:=result+InternalGenerate(TSpkXMLNode(FList[i]),0,UseFormatting);
     end else
         begin
         // Generowanie XMLa dla pojedynczej ga��zi
         case RootNode.NodeType of
              xntNormal : begin
                          if UseFormatting then
                             result:=MkIndent(indent)+'<'+RootNode.name else
                             result:='<'+RootNode.name;

                          if RootNode.Parameters.count>0 then
                              for i:=0 to RootNode.Parameters.count-1 do
                                  result:=result+' '+RootNode.Parameters.ParamByIndex[i].name+'="'+MkText(RootNode.Parameters.ParamByIndex[i].value,false)+'"';

                          if (RootNode.Count=0) and (RootNode.Text='') then
                             begin
                             if UseFormatting then
                                result:=result+'/>'+CRLF else
                                result:=result+'/>';
                             end else
                          if (RootNode.Count=0) and (RootNode.Text<>'') then
                             begin
                             result:=result+'>';
                             result:=result+MkText(RootNode.Text,true);
                             if UseFormatting then
                                result:=result+'</'+RootNode.Name+'>'+CRLF else
                                result:=result+'</'+RootNode.Name+'>';
                             end else
                          if (RootNode.Count>0) and (RootNode.Text='') then
                             begin
                             if UseFormatting then
                                result:=result+'>'+CRLF else
                                result:=result+'>';
                             for i:=0 to RootNode.count-1 do
                                 result:=result+InternalGenerate(RootNode.NodeByIndex[i],indent+2,UseFormatting);

                             if UseFormatting then
                                result:=result+MkIndent(indent)+'</'+RootNode.name+'>'+CRLF else
                                result:=result+'</'+RootNode.name+'>';
                             end else
                          if (RootNode.Count>0) and (RootNode.Text<>'') then
                             begin
                             result:=result+'>';
                             if UseFormatting then
                                result:=result+MkText(RootNode.Text,true)+CRLF else
                                result:=result+MkText(RootNode.Text,true);

                             for i:=0 to RootNode.count-1 do
                                 result:=result+InternalGenerate(RootNode.NodeByIndex[i],indent+2,UseFormatting);

                             if UseFormatting then
                                result:=result+MkIndent(indent)+'</'+RootNode.Name+'>'+CRLF else
                                result:=result+'</'+RootNode.Name+'>';
                             end;
                          end;
              xntControl : begin
                           if UseFormatting then
                              result:=MkIndent(indent)+'<?'+RootNode.Name else
                              result:='<?'+RootNode.Name;
                           if RootNode.Parameters.count>0 then
                              for i:=0 to RootNode.Parameters.count-1 do
                                  result:=result+' '+RootNode.Parameters.ParamByIndex[i].name+'="'+MkText(RootNode.Parameters.ParamByIndex[i].value,false)+'"';

                           if UseFormatting then
                              result:=result+'?>'+CRLF else
                              result:=result+'?>';
                           end;
              xntComment : begin
                           if UseFormatting then
                              result:=MkIndent(indent)+'<!--'+RootNode.text+'-->'+CRLF else
                              result:='<!--'+RootNode.text+'-->';
                           end;
         end;
         end;
  end;

begin
result:=InternalGenerate(nil,0,UseFormatting);
end;

procedure TSpkXMLParser.LoadFromFile(AFile : string);

var sl : TStringList;

begin
sl:=nil;
try
sl:=TStringList.create;
sl.LoadFromFile(AFile);

if length(sl.text)>0 then
   self.Parse(PChar(sl.text));

finally
if sl<>nil then sl.free;
end;
end;

procedure TSpkXMLParser.SaveToFile(AFile : string; UseFormatting : boolean);

var sl : TStringList;

begin
sl:=nil;
try
sl:=TStringList.create;

sl.text:=self.Generate(UseFormatting);

sl.savetofile(AFile);

finally
if sl<>nil then sl.free;
end;
end;

procedure TSpkXMLParser.LoadFromStream(AStream : TStream);

var sl : TStringList;

begin
sl:=nil;
try
sl:=TStringList.create;
sl.LoadFromStream(AStream);

self.Parse(PChar(sl.text));

finally
if sl<>nil then sl.free;
end;
end;

procedure TSpkXMLParser.SaveToStream(AStream : TStream; UseFormatting : boolean);

var sl : TStringList;

begin
sl:=nil;
try
sl:=TStringList.create;

sl.text:=self.Generate(UseFormatting);

sl.savetostream(AStream);

finally
if sl<>nil then sl.free;
end;
end;

end.
