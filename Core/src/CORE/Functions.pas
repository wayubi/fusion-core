unit Functions;

interface

  uses Common;

  // *-- Purpose: Retrieves index at which to add an item.
  function GetInventoryIndex(
    ItemID : Integer = 0;
    SearchItemID : Integer = 0;
    SearchItemType : Integer = 0
  ) : Boolean;

  // *-- Purpose: To transfer an item into an itemlist.
  // *---- Temporary until tc.Item is moved to tc.Inventory.Item for use of Item.AddItem
  function AddItem(
    DestinationItemList : array of TItem;
    ItemIndex : Integer = 0;
    SourceItem : TItem = nil
  ) : Boolean;

implementation

  // *==========================================================================
  // *-- Purpose: Retrieves index at which to add an item.
  // *-- Requires:
  // *---- ItemID to compare to.
  // *---- SearchItemID to search by.
  // *---- SearchItemType to determine how to process.
  // *-- Returns: True on correct inventory index.
  // *==========================================================================

  function GetInventoryIndex(
    ItemID : Integer = 0;
    SearchItemID : Integer = 0;
    SearchItemType : Integer = 0
  ) : Boolean;

  begin

    // *-- Item is not an equipment and item is found or slot is empty
    if (SearchItemType = 0) and ( (ItemID = SearchItemID) or (ItemID = 0) ) then begin
      Result := True;

    // *-- Item is equipment and slot is empty. Item receives its own slot.
    end else if ( (SearchItemType <> 0) and (ItemID = 0) ) then begin
      Result := True;

    // *-- Slot is full and does not match item.
    end else begin    
      Result := False;
      
    end;

  end;
  // *==========================================================================

  // *==========================================================================
  // *-- Purpose: To transfer an item into an itemlist.
  // *---- Temporary until tc.Item is moved to tc.Inventory.Item for use of Item.AddItem
  // *-- Requires:
  // *---- DestinationItemList list to add the item to.
  // *---- ItemIndex location where to add the item.
  // *---- SourceItem to add.
  // *-- Returns: Always true for now.
  // *==========================================================================

  function AddItem(
    DestinationItemList : array of TItem;
    ItemIndex : Integer = 0;
    SourceItem : TItem = nil
  ) : Boolean;

  begin

    // *-- Transfer the item over
    DestinationItemList[ItemIndex-1].ID := SourceItem.ID;
    DestinationItemList[ItemIndex-1].Amount := DestinationItemList[ItemIndex].Amount + SourceItem.Amount;
    DestinationItemList[ItemIndex-1].Equip := SourceItem.Equip;
    DestinationItemList[ItemIndex-1].Identify := SourceItem.Identify;
    DestinationItemList[ItemIndex-1].Refine := SourceItem.Refine;
    DestinationItemList[ItemIndex-1].Attr := SourceItem.Attr;
    DestinationItemList[ItemIndex-1].Card[0] := SourceItem.Card[0];
    DestinationItemList[ItemIndex-1].Card[1] := SourceItem.Card[1];
    DestinationItemList[ItemIndex-1].Card[2] := SourceItem.Card[2];
    DestinationItemList[ItemIndex-1].Card[3] := SourceItem.Card[3];
    DestinationItemList[ItemIndex-1].Data := SourceItem.Data;
    DestinationItemList[ItemIndex-1].Stolen := 0;

  end;
  // *==========================================================================
  
end.
