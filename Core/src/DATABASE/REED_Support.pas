unit REED_Support;

interface

uses
    Common,
    Classes, SysUtils;

    function retrieve_data(idx : Integer; path : String; rtype : Integer = 0) : Variant;
    function get_list(path : String; pfile : String; UID : String = '*') : TStringList;
    procedure retrieve_inventories(path : String; inventory_item : array of TItem);
    function retrieve_length(path : String) : Integer;
    function retrieve_value(path : String; row : Integer; column : Integer) : Variant;

implementation

    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - retrieve_data                                                               }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To retrieve data from the R.E.E.D databases in an efficient manner.          }
    { Parameters:                                                                           }
    {  - idx : Integer, Represents the line from which to retrieve data.                    }
    {  - path : String, Represents the path and file from which to retrieve data.           }
    {  - rtype : Integer, result type designates what type to return. Default String.       }
    {     - Type 0 = String.                                                                }
    {     - Type 1 = Integer.                                                               }
    { ------------------------------------------------------------------------------------- }
    function retrieve_data(idx : Integer; path : String; rtype : Integer = 0) : Variant;
    var
        str : String;
        datafile : TStringList;
    begin
        datafile := TStringList.Create;
        datafile.LoadFromFile(path);
        
        str := Copy(datafile[idx], Pos(' : ', datafile[idx]) + 3, length(datafile[idx]) - Pos(' : ', datafile[idx]) + 3);

        if (rtype = 0) then
            Result := str
        else if (rtype = 1) then
            Result := StrToInt(str);

        FreeAndNil(datafile);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - get_list                                                                    }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To browse directories and retrieve database files in an efficient manner.    }
    { Parameters:                                                                           }
    {  - path : String, Represents the general directory where to search.                   }
    {  - pfile : String, Represents the file to search for.                                 }
    {  - UID : String, Represents the search mask to use in search. Default * (all).        }
    { ------------------------------------------------------------------------------------- }
    function get_list(path : String; pfile : String; UID : String = '*') : TStringList;
    var
        searchResult : TSearchRec;
        filelist : TStringList;
    begin
        filelist := TStringList.Create;
        filelist.Clear;

        SetCurrentDir(path);
        if FindFirst(UID, faDirectory, searchResult) = 0 then repeat
            if FileExists(path + searchResult.Name + '\' + pfile) then begin
                filelist.add(searchResult.Name);
            end;
        until FindNext(searchResult) <> 0;
        FindClose(searchResult);

        Result := filelist;
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - retrieve_inventories                                                        }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To retrieve inventory format databases such as cart/inventory/storage/etc.   }
    { Parameters:                                                                           }
    {  - path : String, Represents file to load up.                                         }
    {  - inventory_item : TItem, Represents the inventory type to clear and reload.         }
    { ------------------------------------------------------------------------------------- }
    procedure retrieve_inventories(path : String; inventory_item : array of TItem);
    var
        datafile : TStringList;
        columns : TStringList;
        i : Integer;
    begin
        datafile := TStringList.Create;
        columns := TStringList.Create;
        columns.Delimiter := ':';

        datafile.LoadFromFile(path);

        for i := 0 to 99 do begin
            inventory_item[i].ID := 0;
        end;

        for i := 2 to datafile.Count - 1 do begin
            columns.DelimitedText := datafile[i];

            inventory_item[i-2].ID := StrToInt(columns.Strings[0]);
            inventory_item[i-2].Amount := StrToInt(columns.Strings[1]);
            inventory_item[i-2].Equip := StrToInt(columns.Strings[2]);
            inventory_item[i-2].Identify := StrToInt(columns.Strings[3]);
            inventory_item[i-2].Refine := StrToInt(columns.Strings[4]);
            inventory_item[i-2].Attr := StrToInt(columns.Strings[5]);
            inventory_item[i-2].Card[0] := StrToInt(columns.Strings[6]);
            inventory_item[i-2].Card[1] := StrToInt(columns.Strings[7]);
            inventory_item[i-2].Card[2] := StrToInt(columns.Strings[8]);
            inventory_item[i-2].Card[3] := StrToInt(columns.Strings[9]);
            inventory_item[i-2].Data := ItemDB.Objects[ItemDB.IndexOf(inventory_item[i-2].ID)] as TItemDB;
        end;

        FreeAndNil(datafile);
        FreeAndNil(columns);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - retrieve_length                                                             }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To retrieve the length of a file for processing and to strip the header.     }
    { Parameters:                                                                           }
    {  - path : String, Represents file to load up.                                         }
    { ------------------------------------------------------------------------------------- }
    function retrieve_length(path : String) : Integer;
    var
        datafile : TStringList;
    begin
        datafile := TStringList.Create;
        datafile.LoadFromFile(path);

        Result := datafile.Count - 3;

        FreeAndNil(datafile);
    end;
    { ------------------------------------------------------------------------------------- }


    { ------------------------------------------------------------------------------------- }
    { R.E.E.D - retrieve_value                                                              }
    { ------------------------------------------------------------------------------------- }
    { Purpose: To retrieve a value from a REED ':' separated data file.                     }
    { Parameters:                                                                           }
    {  - path : String, Represents file to load up.                                         }
    {  - row : Integer, The row index to look for.                                          }
    {  - column : Integer, The column index to look for.                                    }
    { ------------------------------------------------------------------------------------- }
    function retrieve_value(path : String; row : Integer; column : Integer) : Variant;
    var
        datafile : TStringList;
        columns : TStringList;
        i : Integer;
    begin
        datafile := TStringList.Create;
        columns := TStringList.Create;
        columns.Delimiter := ':';

        datafile.LoadFromFile(path);
        columns.DelimitedText := datafile[row + 2];

        Result := columns.Strings[column];

        FreeAndNil(datafile);
        FreeAndNil(columns);
    end;

end.

