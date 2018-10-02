module Dataset exposing
    ( Config
    , putOne, putMany, deleteOne, deleteMany, findOne, findMany
    )

{-| Helpers for CRUD operations

Types

@docs Config

CRUD operations

@docs putOne, putMany, deleteOne, deleteMany, findOne, findMany

-}


{-| Configuration record

`getId` is a function that given a record should return a unique id

-}
type alias Config item id =
    { getId : item -> id
    }


{-| Add or update one record

If the record exising it will be replaced in place.
If the record is new it will added at the end.

-}
putOne : Config a id -> a -> List a -> List a
putOne config item existingItems =
    putMany config [ item ] existingItems


{-| Add or update many record
-}
putMany : Config a id -> List a -> List a -> List a
putMany config newItems existingItems =
    let
        existingIds =
            List.map config.getId existingItems

        isInExistingIds item =
            List.member (config.getId item) existingIds

        ( updates, added ) =
            newItems
                |> List.partition isInExistingIds

        updatedItems =
            existingItems
                |> List.map (replaceItem config updates)
    in
    updatedItems ++ added


replaceItem : Config a id -> List a -> a -> a
replaceItem config updatedItems currentItem =
    let
        itemId =
            config.getId currentItem
    in
    case findOne config itemId updatedItems of
        Just item ->
            item

        Nothing ->
            currentItem


{-| Delete one record from the collection

    deleteOne config 1 collection

-}
deleteOne : Config a id -> id -> List a -> List a
deleteOne config id items =
    deleteMany config [ id ] items


{-| Delete many records from the collection

    deleteMany config [ 1, 2 ] collection

-}
deleteMany : Config a id -> List id -> List a -> List a
deleteMany config ids items =
    items |> List.filter (itemsHasIdIn config ids >> not)


{-| Find one record in the collection by id

    findOne config 1 collection ==> Maybe item

-}
findOne : Config a id -> id -> List a -> Maybe a
findOne config id items =
    items
        |> List.filter (itemsHasIdIn config [ id ])
        |> List.head


{-| Find several records in the collection by id

    findMany config [ 1, 2 ] collection ==> [..items..]

-}
findMany : Config a id -> List id -> List a -> List a
findMany config ids items =
    List.filter (itemsHasIdIn config ids) items



-- Utils


itemsHasIdIn : Config a id -> List id -> a -> Bool
itemsHasIdIn config ids item =
    List.member (config.getId item) ids
