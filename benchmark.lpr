program benchmark;
{$ifdef FPC}
{$mode delphi}
{$endif}

{$apptype console}

{$undef USE_FASTMM}
uses
  {$ifdef USE_FASTMM}FastMM4 ,{$endif}
  Classes, SysUtils, iardict, {ghashmap ,} generics.collections, hash ;

type
  TRnd = array[0..15] of QWord;
  TArrRnd = array[0..1000000-1] of TRnd;

var
  t: TIarDict;
  counter: longint;
  start: QWord;
  rnd: TRnd;
  gdict: TDictionary<TRnd, Pointer>;
  //ghm: ghashmap.THashmap<TRnd, Pointer, hint>;
  v: Pointer;
  i: integer;

  frDict: TStringList;
  wrd: String;
  arrRnd: TArrRnd;

begin

  for counter := 0 to 1000000-1 do
    for i := 0 to Length(TRnd) - 1 do
      arrRnd[counter][i] := Random(QWord.MaxValue);

  start := GetTickCount64();

  {
  for counter := 1 to 10000000 do
  begin
    t.AddOrUpdate('Hellz', 5);
    t.AddOrUpdate('AbraKadabra', 11);

    t.AddOrUpdate('Halli', 5);
    t.AddOrUpdate('AbrzKadabr0', 11);
  end;
  WriteLn(t.keyNum);
  for counter := 1 to 10000000 do
  begin
    t.Find('Hello', 5);
    t.Find('Hellz', 5);
    t.Find('Halli', 5);
    t.Find('AbraKadabra', 11);
  end;

  WriteLn(t.Find('Hello', 5));
  WriteLn(t.Find('Hellz', 5));
  WriteLn(t.Find('Halli', 5));
  WriteLn(t.Find('AbraKadabra', 11));

  WriteLn('Ticks - ', GetTickCount64() - start);
  }

  start := GetTickCount64();
  t.Init(FNV1A_Hash_Meiyan, 1000000);
  WriteLn('Key size - ', SizeOf(TRnd));
  WriteLn('--------');
  WriteLn('IarDict - Insert 1000000 random ...');
  for counter := 0 to 1000000-1 do
  begin
    t.Insert(PChar(@arrRnd[counter][0]), SizeOf(TRnd), Pointer(i));

    if not t.Find(PChar(@arrRnd[counter][0]), SizeOf(TRnd), v) then
    begin
      WriteLn('Error.');
      break;
    end;
    if v <> Pointer(i) then
    begin
      WriteLn('Error.');
      break;
    end;
{
    for i := 0 to Length(rnd) - 1 do
      rnd[i] := Random();
    t.Remove(PChar(@rnd[0]), SizeOf(rnd));
}
  end;
  WriteLn('      Ticks - ', GetTickCount64() - start);
  WriteLn('       Keys - ', t.keyNum);
  WriteLn('   Capacity - ', t.capacity);
  WriteLn('Used blocks - ', t.UsedBlocks);
  WriteLn(Format('Load factor - %g', [t.keyNum / t.capacity]));

  t.SetValues(Pointer(0));
  WriteLn('Ticks with SetValues - ', GetTickCount64() - start);

  t.Clear();
  WriteLn('Ticks with free - ', GetTickCount64() - start);

  //halt(70);

  gdict := TDictionary<TRnd, Pointer>.Create(1000000);
  start := GetTickCount64();
  WriteLn('.......................................');
  WriteLn('TDictionary - Insert 1000000 random ...');
  for counter := 0 to 1000000-1 do
  begin
    gdict.AddOrSetValue(arrRnd[counter], Pointer(i));

    if not gdict.TryGetValue(arrRnd[counter], v) then
    begin
      WriteLn('Error.');
      break;
    end;
    if v <> Pointer(i) then
    begin
      WriteLn('Error.');
      break;
    end;
{
    for i := 0 to Length(rnd) - 1 do
      rnd[i] := Random();
    gdict.Remove(rnd);
}
  end;
  WriteLn('Ticks - ', GetTickCount64() - start);
  WriteLn('Keys - ', gdict.Count);
  WriteLn('Capacity - ', gdict.Capacity);
  FreeAndNil(gdict);
  WriteLn('Ticks wiht free - ', GetTickCount64() - start);


  WriteLn('IarDict - Insert French words ...');

  frDict := TStringList.Create();
  frDict.LoadFromFile('dic_fr.txt');
  start := GetTickCount64();
  t.Init(FNV1A_Hash_Meiyan);
  for wrd in frDict do
    t.Insert(PChar(wrd), Length(wrd), Pointer(0));
  WriteLn('Ticks - ', GetTickCount64() - start);
  WriteLn('Keys - ', t.keyNum);
  WriteLn('Used blocks - ', t.UsedBlocks);

  WriteLn('Find insert order ...');
  for wrd in frDict do
    if not t.Find(PChar(wrd), Length(wrd), v) then
    begin
      WriteLn('Err');
      break;
    end;
  WriteLn('Ticks - ', GetTickCount64() - start);

  for wrd in frDict do
    t.Remove(PChar(wrd), Length(wrd));

  WriteLn('Keys - ', t.keyNum);
  WriteLn('Ticks - ', GetTickCount64() - start);

  t.Clear();
  WriteLn('Ticks with free - ', GetTickCount64() - start);

  frDict.free();

end.

