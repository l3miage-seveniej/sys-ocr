%dw 2.4

import * from dw::core::Arrays

var allBlocks = payload.Blocks

fun searchChildren(childIds) = (allBlocks filter (childIds contains $.Id))
fun searchLastChildren(childIds) =  if(isEmpty(getRelationships(searchChildren(childIds))))
                                    searchChildren(childIds) 
                                    else  
                                    searchLastChildren(getRelationshipsType(searchChildren(childIds), "CHILD"))
fun getRelationships(block) = flatten(block..Relationships)
fun getRelationshipsType(block, relationType) = flatten((getRelationships(block) filter $.Type == relationType).Ids)
fun getEntityTypes(entityType) = flatten(allBlocks filter ($.EntityTypes contains entityType))
fun searchBlockType(blockType) = flatten((allBlocks filter ((item, index) -> item.BlockType == blockType)))
fun getTableEntity(tableBlock, entity) = getEntityTypes(entity) map {
    positionX: $.ColumnIndex,
    positionY: $.RowIndex,
    value: searchChildren(getRelationshipsType($, "CHILD"))..Text joinBy " "
}
fun getTableValues(tableBlock) = (tableBlock filter $.EntityTypes == null) map {
    positionY: $.RowIndex,
    positionX: $.ColumnIndex,
    value: searchChildren(getRelationshipsType($, "CHILD"))..Text joinBy " "
}

fun associateValues(headers, values) = (values filter $.value != null) map ((item, index) -> {
        ((headers filter $.positionX == item.positionX)[0].value):item.value,
        positionY: item.positionY,
        positionX: item.positionX
    }) groupBy $.positionY 
    mapObject ((value, key, index) -> { (key):(value reduce ((item, acc={}) -> item - "positionY" - "positionX" ++ acc))})
    pluck($)
