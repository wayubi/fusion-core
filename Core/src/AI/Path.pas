unit Path;



interface

uses
	Windows, SysUtils, Common;

//==============================================================================
// �֐���`
		function  DirMove(tm:TMap; var xy:TPoint; Dir:byte; bb:array of byte):boolean;

		function  CanMove(tm:TMap; x0, y0, x1, y1:integer):boolean;
		procedure AddPath2(var aa:array of rHeap; var n:byte; rh:rHeap; x1, y1, x2, y2, dx, dy, dir, dist:integer);
		function  SearchPath2(var path:array of byte; tm:TMap; x1, y1, x2, y2:cardinal):byte;

        function  CanAttack(tm:TMap; x0, y0, x1, y1:integer):boolean;
        function  SearchAttack(var path:array of byte; tm:TMap; x1, y1, x2, y2:cardinal):byte;


		procedure PopHeap(var aa:array of rHeap;var n:byte);
		procedure PushHeap(var d:rHeap; var aa:array of rHeap;var n:byte);
		procedure UpHeap(x:byte; var aa:array of rHeap;var n:byte);
//==============================================================================










implementation

function CanAttack(tm:TMap; x0, y0, x1, y1:integer):boolean;
var
	b1 :byte;
	b2 :byte;
begin

    Result := false;

    if (x0 - x1 < -1) or (x0 - x1 > 1) or (y0 - y1 < -1) or (y0 - y1 > 1) then exit;
    if (x1 < 0) or (y1 < 0) or (x1 >= tm.Size.X) or (y1 >= tm.Size.Y) then exit;

    b1 := tm.gat[x0][y0];
    if (b1 = 1) then exit;

    b2 := tm.gat[x1][y1];
    if (b2 = 1) then exit;

    if (x0 = x1) or (y0 = y1) then begin
        Result := true;
        exit;
    end;

    b1 := tm.gat[x0][y1];
    b2 := tm.gat[x1][y0];

    if (b1 = 1) or (b2 = 1) then exit;

    Result := true;

end;

function SearchAttack(var path:array of byte; tm:TMap; x1, y1, x2, y2:cardinal):byte;
var
	aa	:array[0..255] of rHeap;
	x, y:integer;
	rh	:rHeap;
	n		:byte;
	//cost:word;
	//str:string;
	i, j:integer;
begin
	ZeroMemory(@aa, sizeof(aa));
	aa[1].x := x1;
	aa[1].y := y1;
	aa[1].mx := 15;
	aa[1].my := 15;
	aa[1].cost2 := 0;
	aa[1].cost1 := 1;
	//aa[1].dir := 0;
	aa[1].pcnt := 0;
	n := 1;
	ZeroMemory(@mm, sizeof(mm));
	mm[15][15].cost := 1;
	mm[15][15].addr := 1;

  {Mitch: The problem with the not being able to attack a monster
  if you're stuck on it was right here. Since it breaks out of the
  while when the aa[1].x = x2 and aa[1].y = y2 (where the monster was at!)
	OLD CODE: while (n <> 0) and ((aa[1].x <> x2) or (aa[1].y <> y2)) do begin
  I removed the last 2 conditions so hopefully its fixed?

  Colus, 20040129: No, it is not fixed.  You can't attack _anything_ if the
  code is like this!  The result will still be 0, you will walk up to the
  monster and not do anything.}

  //while (n <> 0) do begin
  while (n <> 0) and ((aa[1].x <> x2) or (aa[1].y <> y2)) do begin
		rh := aa[1];
		PopHeap(aa, n);

    // AlexKreuz new searchpath logic -> Less Calculations = Better performance.
    if (x2 > x1) then begin
      if (y2 > y1) then begin
    		if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y  ) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  0, 6, 10);
    		if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  1, 7, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x  , rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  0,  1, 0, 10);
      end else if (y2 < y1) then begin
    		if CanAttack(tm, rh.x, rh.y, rh.x  , rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  0, -1, 4, 10);
        if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1, -1, 5, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y  ) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  0, 6, 10);
      end else if (y2 = y1) then begin
    		if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1, -1, 5, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y  ) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  0, 6, 10);
    		if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  1, 7, 14);
      end;
    end else if (x2 < x1) then begin
      if (y2 > y1) then begin
    		if CanAttack(tm, rh.x, rh.y, rh.x  , rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  0,  1, 0, 10);
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  1, 1, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y  ) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  0, 2, 10);
      end else if (y2 < y1) then begin
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y  ) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  0, 2, 10);
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x  , rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  0, -1, 4, 10);
      end else if (y2 = y1) then begin
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  1, 1, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y  ) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  0, 2, 10);
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
      end;
    end else if (x2 = x1) then begin
      if (y2 > y1) then begin
    		if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  1, 7, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x  , rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  0,  1, 0, 10);
    		if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y+1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  1, 1, 14);
      end else if (y2 < y1) then begin
        if CanAttack(tm, rh.x, rh.y, rh.x+1, rh.y-1) then
          AddPath2(aa, n, rh, x1, y1, x2, y2,  1, -1, 5, 14);
        if CanAttack(tm, rh.x, rh.y, rh.x-1, rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
    		if CanAttack(tm, rh.x, rh.y, rh.x  , rh.y-1) then
    			AddPath2(aa, n, rh, x1, y1, x2, y2,  0, -1, 4, 10);
      end;
    end;

	end;
	if n = 0 then begin
		Result := 0;
		exit;
	end;

	x := aa[1].mx;
	y := aa[1].my;

	if mm[x][y].cost <> 0 then begin
		CopyMemory(@path, @mm[x][y].path, mm[x][y].pcnt);
		Result := mm[x][y].pcnt;
	end else begin
		Result := 0;
	end;

end;

//==============================================================================
function DirMove(tm:TMap; var xy:TPoint; Dir:byte; bb:array of byte):boolean;
var
	i:integer;
	xy1:TPoint;
begin
	Result := false;
	for i := 0 to Length(bb) - 1 do begin
		xy1 := xy;
		case (bb[i] + Dir) mod 8 of
		0: begin           Inc(xy.Y); end;
		1: begin Dec(xy.X);Inc(xy.Y); end;
		2: begin Dec(xy.X);           end;
		3: begin Dec(xy.X);Dec(xy.Y); end;
		4: begin           Dec(xy.Y); end;
		5: begin Inc(xy.X);Dec(xy.Y); end;
		6: begin Inc(xy.X);           end;
		7: begin Inc(xy.X);Inc(xy.Y); end;
		end;
		if ((tm.gat[xy.X][xy.Y] = 1) or (tm.gat[xy.X][xy.Y] = 5)) then begin
			xy := xy1;
			exit;
		end;
	end;
end;
//------------------------------------------------------------------------------
function CanMove(tm:TMap; x0, y0, x1, y1:integer):boolean;
var
	b1 :byte;
	b2 :byte;
begin

    Result := false;

    if (x0 - x1 < -1) or (x0 - x1 > 1) or (y0 - y1 < -1) or (y0 - y1 > 1) then exit;
    if (x1 < 0) or (y1 < 0) or (x1 >= tm.Size.X) or (y1 >= tm.Size.Y) then exit;

    b1 := tm.gat[x0][y0];
    if (b1 = 1) or (b1 = 5) then exit;

    b2 := tm.gat[x1][y1];
    if (b2 = 1) or (b2 = 5) then exit;

    if (x0 = x1) or (y0 = y1) then begin
        Result := true;
        exit;
    end;

    b1 := tm.gat[x0][y1];
    b2 := tm.gat[x1][y0];

    if (b1 = 1) or (b1 = 5) or (b2 = 1) or (b2 = 5) then exit;

    Result := true;

end;

{	Result := false;
	if (x0 - x1 < -1) or (x0 - x1 > 1) or (y0 - y1 < -1) or (y0 - y1 > 1) then exit;
	if (x1 < 0) or (y1 < 0) or (x1 >= tm.Size.X) or (y1 >= tm.Size.Y) then exit;
	b1 := tm.gat[x0][y0];
	if (b1 and 1) = 0 then exit;
	b1 := tm.gat[x1][y1];
  if (b1 and 1) = 0 then exit;
  if (x0 = x1) or (y0 = y1) then begin
    Result := true;
    exit;
  end;
  b1 := tm.gat[x0][y1];
  b2 := tm.gat[x1][y0];
	if ((b1 and 1) = 0) or ((b2 and 1) = 0) then exit;

  Result := true;  }

//------------------------------------------------------------------------------
procedure AddPath2(var aa:array of rHeap; var n:byte; rh:rHeap; x1, y1, x2, y2, dx, dy, dir, dist:integer);
var
	x, y:integer;
	rh1	:rHeap;
	cost:word;
begin
	x := rh.mx + dx;
	if (x < 0) or (x > 30) then exit;
	y := rh.my + dy;
	if (y < 0) or (y > 30) then exit;
	cost := rh.cost2 + dist + (abs(x2 - (rh.x + dx)) + abs(y2 - (rh.y + dy))) * 10;
	if mm[x][y].cost <> 0 then begin
		//���܂łɓ����_���������Ȃ�cost���r���������Ȃ�V����path�ł��̓_���ēo�^
		if mm[x][y].cost > cost then begin
			rh1.x := rh.x + dx;
			rh1.y := rh.y + dy;
			rh1.mx := x;
			rh1.my := y;
			rh1.cost2 := rh.cost2 + dist;
			rh1.cost1 := cost;
			//rh1.dir := dir;
			CopyMemory(@rh1.path, @rh.path, rh.pcnt);
			rh1.pcnt := rh.pcnt + 1;
			rh1.path[rh.pcnt] := dir;
			mm[x][y].cost := cost;
			mm[x][y].pcnt := rh1.pcnt;
			CopyMemory(@mm[x][y].path, @rh1.path, rh1.pcnt);
			if mm[x][y].addr <> 0 then begin
				aa[mm[x][y].addr] := rh1;
				UpHeap(mm[x][y].addr, aa, n);
			end else begin
				mm[x][y].addr := n;
				PushHeap(rh1, aa, n);
			end;
		end;
	end else begin
			//�����_���Ȃ���΂��̓_��o�^
			rh1.x := rh.x + dx;
			rh1.y := rh.y + dy;
			rh1.mx := x;
			rh1.my := y;
			rh1.cost2 := rh.cost2 + dist;
			rh1.cost1 := cost;
			//rh1.dir := dir;
			CopyMemory(@rh1.path, @rh.path, rh.pcnt);
			rh1.pcnt := rh.pcnt + 1;
			rh1.path[rh.pcnt] := dir;
			mm[x][y].cost := cost;
			mm[x][y].pcnt := rh1.pcnt;
			CopyMemory(@mm[x][y].path, @rh1.path, rh1.pcnt);
			mm[x][y].addr := n + 1;
			PushHeap(rh1, aa, n);
	end;
end;
//------------------------------------------------------------------------------
function SearchPath2(var path:array of byte; tm:TMap; x1, y1, x2, y2:cardinal):byte;
var
	aa	:array[0..255] of rHeap;
	x, y:integer;
	rh	:rHeap;
	n		:byte;
	//cost:word;
	//str:string;
	i, j:integer;
begin
	ZeroMemory(@aa, sizeof(aa));
	aa[1].x := x1;
	aa[1].y := y1;
	aa[1].mx := 15;
	aa[1].my := 15;
	aa[1].cost2 := 0;
	aa[1].cost1 := 1;
	//aa[1].dir := 0;
	aa[1].pcnt := 0;
	n := 1;
	ZeroMemory(@mm, sizeof(mm));
	mm[15][15].cost := 1;
	mm[15][15].addr := 1;
	
	while (n <> 0) and ((aa[1].x <> x2) or (aa[1].y <> y2)) do begin
		rh := aa[1];
		PopHeap(aa, n);

        // AlexKreuz SearchPath v.2.0
        if (x2 > rh.x) then begin
            if (y2 > rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x+1, rh.y+1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 1, 7, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, 1, 0, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 0, 6, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 1, 1, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, -1, 5, 14);
                end;
            end else if (y2 < rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x+1, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, -1, 5, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x, rh.y-1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, -1, 4, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 0, 6, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y-1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y+1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 1, 7, 14);
                end;
            end else if (y2 = rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x+1, rh.y) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 0, 6, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x+1, rh.y-1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y+1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, -1, 5, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 1, 7, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, 1, 0, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, -1, 4, 10);
                end;
            end;
        end else if (x2 < rh.x) then begin
            if (y2 > rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y+1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 1, 1, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x-1, rh.y) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, 1, 0, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 0, 2, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y-1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y+1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 1, 7, 14);
                end;
            end else if (y2 < rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y) or CanMove (tm, rh.x, rh.y, rh.x, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 0, 2, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, -1, 4, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 1, 1, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, -1, 5, 14);
                end;
            end else if (y2 = rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 0, 2, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x-1, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 1, 1, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, 1, 0, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, -1, 4, 10);
                end;
            end;
        end else if (x2 = rh.x) then begin
            if (y2 > rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x, rh.y+1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, 1, 0, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y+1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y+1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 1, 1, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 1, 7, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 0, 2, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 0, 6, 10);
                end;
            end else if (y2 < rh.y) then begin
                if CanMove (tm, rh.x, rh.y, rh.x, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 0, -1, 4, 10);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y-1) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y-1) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, -1, 5, 14);
                end else if CanMove (tm, rh.x, rh.y, rh.x-1, rh.y) or CanMove (tm, rh.x, rh.y, rh.x+1, rh.y) then begin
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, -1, 0, 2, 10);
                    AddPath2 (aa, n, rh, x1, y1, x2, y2, 1, 0, 6, 10);
                end;
            end;
        end;
        // AlexKreuz SearchPath v.2.0

        // Old Search Path calculations.
		{if CanMove(tm, rh.x, rh.y, rh.x+1, rh.y  ) then
			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  0, 6, 10);
		if CanMove(tm, rh.x, rh.y, rh.x+1, rh.y-1) then
			AddPath2(aa, n, rh, x1, y1, x2, y2,  1, -1, 5, 14);
		if CanMove(tm, rh.x, rh.y, rh.x+1, rh.y+1) then
			AddPath2(aa, n, rh, x1, y1, x2, y2,  1,  1, 7, 14);
		if CanMove(tm, rh.x, rh.y, rh.x  , rh.y+1) then
			AddPath2(aa, n, rh, x1, y1, x2, y2,  0,  1, 0, 10);
		if CanMove(tm, rh.x, rh.y, rh.x-1, rh.y+1) then
			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  1, 1, 14);
		if CanMove(tm, rh.x, rh.y, rh.x-1, rh.y  ) then
			AddPath2(aa, n, rh, x1, y1, x2, y2, -1,  0, 2, 10);
		if CanMove(tm, rh.x, rh.y, rh.x-1, rh.y-1) then
			AddPath2(aa, n, rh, x1, y1, x2, y2, -1, -1, 3, 14);
		if CanMove(tm, rh.x, rh.y, rh.x  , rh.y-1) then
			AddPath2(aa, n, rh, x1, y1, x2, y2,  0, -1, 4, 10); }
        // Old Search Path calculations.

	end;
	if n = 0 then begin
		Result := 0;
		exit;
	end;

	x := aa[1].mx;
	y := aa[1].my;

	if mm[x][y].cost <> 0 then begin
		CopyMemory(@path, @mm[x][y].path, mm[x][y].pcnt);
		Result := mm[x][y].pcnt;
	end else begin
		Result := 0;
	end;

end;
//------------------------------------------------------------------------------
// �q�[�v����ŏ��̗v�f���폜����
procedure PopHeap(var aa:array of rHeap;var n:byte);
var
	i, j	:cardinal;
begin
	// �q�[�v����łȂ����Ƃ��m�F����
	if n < 1 then exit;

	// �q�[�v�̍ŏ��̗v�f���폜����
	mm[aa[1].mx][aa[1].my].addr := 0;

	// �����珉�߂āC�߂����q�������Ă������J��Ԃ�
	i := 1;
	while i <= (n div 2) do begin // �t�����߂� 1..n/2
		// �߂��̎q�̂����A�������������Ƃ���
		j := i * 2;
		if (j+1 <= n) and (aa[j].cost1 >= aa[j+1].cost1) then Inc(j);
		// �߂��ɐ߂��̒l�����āC�߂��ɒ��ڂ���
		aa[i] := aa[j];
		mm[aa[i].mx][aa[i].my].addr := i;
		i := j;
	end;

	// �q�[�v�̍Ō�̗v�f���i�Ɉړ�����
	if i <> n then begin
		aa[i] := aa[n];
		mm[aa[i].mx][aa[i].my].addr := i;
		Dec(n);
		UpHeap(i, aa, n);
	end else begin
		Dec(n);
	end;
end;
{
procedure PopHeap(var aa:array of rHeap;var n:byte);
var
	i, j	:cardinal;
	val		:cardinal;
	rh		:rHeap;
begin
	// �q�[�v����łȂ����Ƃ��m�F����
	if n < 1 then exit;

	// �q�[�v�̍Ō�̗v�f��擪�Ɉړ�����
	mm[aa[1].mx][aa[1].my].addr := 0;
	aa[1] := aa[n];
	Dec(n);

	// ���߂���v�f�̒l�� val �ɃZ�b�g���Ă���
	rh := aa[1];
	val := rh.cost1;

	// �����珉�߂āC�߂����q�������Ă������J��Ԃ�
	i := 1;
	while i <= (n div 2) do begin // �t�����߂� 1..n/2
		// �߂��̎q�̂����A�������������Ƃ���
		j := i * 2;
		if (j+1 <= n) and (aa[j].cost1 >= aa[j+1].cost1) then Inc(j);
		// �����C�e���q���傫���Ȃ��Ƃ����֌W�����藧�Ă΁C
		// ����ȏ㒾�߂�K�v�͂Ȃ�
		if val <= aa[j].cost1 then break;
		// �߂��ɐ߂��̒l�����āC�߂��ɒ��ڂ���
		aa[i] := aa[j];
		mm[aa[i].mx][aa[i].my].addr := i;
		i := j;
	end;

	//�擪�ɂ������v�f��߂��ɓ����
	aa[i] := rh;
	mm[aa[i].mx][aa[i].my].addr := i;
end;
}
//------------------------------------------------------------------------------
// �q�[�v�ɗv�f��o�^����
procedure PushHeap(var d:rHeap; var aa:array of rHeap;var n:byte);
var
	i		:cardinal;
	val	:cardinal;
	rh		:rHeap;
begin
	Inc(n);
	aa[n] := d;

	// �����яオ�点��v�f�̒l�� val �ɓ���Ă���
	rh := aa[n];
	val := rh.cost1;
	// �v�f�����܂ŕ����яオ���Ă��Ȃ��C����
	// �u�e���q���傫���v�������J��Ԃ�
	i := n;
	while (i > 1) and (aa[i div 2].cost1 > val) do begin
		// �e�̒l���q�Ɉڂ�
		aa[i] := aa[i div 2];
		mm[aa[i].mx][aa[i].my].addr := i;
		i := i div 2;
	end;

	// �ŏI�I�ȗ��������悪���܂���
	aa[i] := rh;
	mm[aa[i].mx][aa[i].my].addr := i;
end;
//------------------------------------------------------------------------------
// �q�[�v���� x �Ԗڂ̗v�f��K�v�ȏꏊ�܂ŕ����яオ�点��
procedure UpHeap(x:byte; var aa:array of rHeap;var n:byte);
var
	i		:cardinal;
	val	:cardinal;
	rh		:rHeap;
begin
	// �����яオ�点��v�f�̒l�� val �ɓ���Ă���
	rh := aa[x];
	val := rh.cost1;
	// �v�f�����܂ŕ����яオ���Ă��Ȃ��C����
	// �u�e���q���傫���v�������J��Ԃ�
	i := x;
	while (i > 1) and (aa[i div 2].cost1 > val) do begin
		// �e�̒l���q�Ɉڂ�
		aa[i] := aa[i div 2];
		mm[aa[i].mx][aa[i].my].addr := i;
		i := i div 2;
	end;

	// �ŏI�I�ȗ��������悪���܂���
	aa[i] := rh;
	mm[aa[i].mx][aa[i].my].addr := i;
end;
//==============================================================================
end.
