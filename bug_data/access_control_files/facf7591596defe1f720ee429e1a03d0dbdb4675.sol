pragma solidity^0.4.11;

pragma solidity ^0.4.11;

library TreeLib{

    /* Base structures, members can be combined to create the right structure

    struct Base{ //Base members required by all structures
        bytes32 id;//Id of the structure
        uint mtype;//Type of structure [ increses from 0 for the base structure (main nodes) ]
    }

    struct Sibling{ //members for structures which have siblings
        bytes32 left; //Id to sibling on the left
        bytes32 right; //Id to sibling on the right
    }

    struct Group{ //members for structures which are parents
        uint size; //Total number of children
        uint maxsize; //Max allowed number of children
        bytes32 root; //Id for the first child
        bytes32 last; //Id for the last child
        mapping(bytes32=>Base) children //List of children, type of child has to be a valid type to work
    }

    struct Child{ //members for structure which have parents
        bytes32 parent;//Id of the parent
    }

    struct Content{ //Actual data members
        bytes32 data;//Actual data being saved, could be changed to desired type
    }
    */

    struct Node{ //The base structure
        uint mtype;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 parent;
        bytes32 data;
    }

    struct Section{ //The structure having Nodes as its children
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 root;
        bytes32 last;
        bytes32 parent;
        mapping(bytes32=>Node) children;
    }

    /*
    //Only enabled if max_dept >2
    struct SubSection{ //The intermediarry structure, multiple layers can exist under one Index
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 parent;
        mapping(bytes32=>Section) children; //Can either be SubSections or Sections
    }

    //Only enabled if max_dept >3
    struct SupSection{ //The intermediarry structure, multiple layers can exist under one Index
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 left;
        bytes32 right;
        bytes32 parent;
        mapping(bytes32=>SubSection) children; //Can either be SubSections or Sections
    }

    //Add more types as necessary based on Max depth
    */

    struct Index{ //The highest structure
        uint mtype;
        uint size;
        uint maxsize;
        bytes32 id;
        bytes32 root;
        bytes32 last;
        mapping(bytes32=>Section) children;
    }


    function getNode(Section storage sector, bytes32 node_id) constant returns (bytes32 id,bytes32 left,bytes32 right,bytes32 parent,bytes32 data){
        //set returns based on nature of base node
        //set correct type of parent of Node as designed

        return (sector.children[node_id].id,sector.children[node_id].left,sector.children[node_id].right,sector.children[node_id].parent,sector.children[node_id].data);
    }

    function removeSection(Index storage index,bytes32 section_id) internal {
      require(index.children[section_id].id == section_id);
      Section storage sector = index.children[section_id];

      index.children[sector.left].right = sector.right;
      if(index.root == section_id)
      index.root = sector.right;

      index.children[sector.right].left = sector.left;
      if(index.last == section_id)
      index.last = sector.left;

      delete(index.children[section_id]);
      if(index.size>0)
      index.size--;
    }

    function removeNode(Section storage sector,bytes32 node_id){
      require(sector.children[node_id].id == node_id);
      Node storage node = sector.children[node_id];

      sector.children[node.left].right = node.right;
      if(sector.root == node_id)
      sector.root = node.right;

      sector.children[node.right].left = node.left;
      if(sector.last == node_id)
      sector.last = node.left;

      delete(sector.children[node_id]);
      if(sector.size>0)
      sector.size--;
    }

    function newIndex(bytes32 index_id,uint maxsize) internal returns(Index memory) {
        return Index(2,0,maxsize,index_id,0x0,0x0); //Update "2" to match ltype index for structure
    }

    function newSection(bytes32 section_id,bytes32 left_id,bytes32 parent_id,uint maxsize) internal returns(Section memory section) {
        return Section(1,0,maxsize,section_id,left_id,0x0,0x0,0x0,parent_id);//Update "1" to match ltype index for structure
    }

    function newNode(bytes32 node_id ,bytes32 left_id,bytes32 right_id,bytes32 parent_id,bytes32 data) internal returns(Node memory node) {
        return Node(0,node_id,left_id,right_id,parent_id,data);//Update initial "0" to match ltype index for structure
    }

    function insertSection(Index storage index,bytes32 section_id) internal { //Create correspondong insert functions for other intermediate types
        require(index.size < index.maxsize);

        if(index.size < 1){
            index.root = section_id;
        }
        else{
            index.children[index.last].right = section_id;
        }
        index.children[section_id] = newSection(section_id,index.last,index.id,index.maxsize);
        index.last = section_id;
        index.size ++;
    }

    function insertNode(Section storage sector,bytes32 node_id,bytes32 data) internal {
        require(sector.size < sector.maxsize);


        if(sector.size < 1){
            sector.root = node_id;
        }
        else{
            sector.children[sector.last].right = node_id;
        }

        sector.children[node_id] = newNode(node_id,sector.last,0x0,sector.id,data);
        sector.last = node_id;
        sector.size ++;
    }

    function insertNodeBatch(Section storage sector,bytes32 left,bytes32 right,bytes32 node_id,bytes32 data) internal {

        if(sector.size < 1){
            sector.root = node_id;
        }

        sector.children[node_id] = newNode(node_id,left,right,sector.id,data);
        sector.last = node_id;
        sector.size ++;
    }

}

contract Tree{

    mapping(bytes32=>TreeLib.Index) indexes;//Or a single index, based on how you want to arange your indexes
    mapping(bytes32=>bytes32) parent_child_lookup;

    uint max_depth=2; // Maxdepth of the tree; advised 5
    uint mtypes_count=3;//Count of mtypes,available structure types from the lib
    bytes8[3] mtypes = [ bytes8("Node"), bytes8("Section"), bytes8("Index")]; //Increase type to match structure types
    enum ltypes {Node,Section,Index} //Increase type to match structure types


    uint parent_max_size = 10; //Max size for all parents equaling Max nodes = parent_max_size^(max_depth-1)

    function TreeContract(){
    }

    function indexExists(bytes32 index_id) constant returns (bool){
        return (indexes[index_id].id == index_id);
    }

    function childExists(bytes32 child_id) constant returns(bool){
        return (getParent(child_id) != 0x0);
    }

    function nodeExists(bytes32 index_id,bytes32 node_id) constant returns(bool){
        if(childExists(node_id) ){
          return getHeirachy(node_id)[1] == index_id;
        }
        return false;
    }

    function getParent(bytes32 child_id) constant returns(bytes32){
        return parent_child_lookup[child_id];
    }

    function getHeirachy(bytes32 child_id) constant returns (bytes32[2] memory search_up /*should match (max_depth)*/){
        bytes32 main_index_id;

        //Fetch the node's parent
        main_index_id = getParent(child_id);
        search_up[0] = main_index_id;

        uint i = 1;
        while((main_index_id = getParent(main_index_id)) != 0x0){
        search_up[i] = main_index_id;
        i++;
        }
    }

    function nextSection(bytes32 index_id) internal constant returns (bytes32 id){
      //get the next available section in the index
      TreeLib.Index storage index = indexes[index_id];
      id = indexes[index_id].root;
      while(true){
        if(index.children[id].size+1 > index.maxsize && index.children[id].id != 0x0){
          id = index.children[id].right;
          continue;
        }
        else break;
      }
      return id;
    }

    function getSection(bytes32 section_id) internal constant returns(TreeLib.Section storage sector){
        bytes32[2] memory search_up; //size should match (max_depth)
        search_up = getHeirachy(section_id);

        //GenecricTree.SubSection storage subsector; //Only enabled if max_dept >2
        //Structure based on sector parent being index
        if(search_up.length>0){
          sector = indexes[search_up[0]].children[section_id];
        }
    }

    function getIndex(bytes32 index_id)constant returns(uint mtype,uint size, uint maxsize, bytes32 id, bytes32 root, bytes32 last){

        TreeLib.Index memory index = indexes[index_id];
        return (index.mtype,index.size,index.maxsize,index.id,index.root,index.last);
    }

    function getNode(bytes32 node_id) constant returns (bytes32 id,bytes32 left,bytes32 right,bytes32 parent,bytes32 data){
        //set returns based on nature of base node
        //require(child_type_lookup[node_id] == ltypes.Node);
        return TreeLib.getNode(getSection(getParent(node_id)),node_id);
    }

    function getNodesBatch(bytes32 index_id,bytes32 last_node_id) constant returns (bytes32[5][5] results) {
          TreeLib.Index storage index = indexes[index_id];

          //throw if empty
          require(index.size>0);

          if(last_node_id == 0x0)last_node_id = index.children[index.root].root;
          else last_node_id = index.children[getParent(last_node_id)].children[last_node_id].right;

          bytes32 section_id = getParent(last_node_id);
          TreeLib.Section storage sector = index.children[section_id];

          uint r = 0;

          while(r<5 && last_node_id!=0x0){
           results[0][r]= sector.children[last_node_id].id;
           results[1][r]= sector.children[last_node_id].left;
           results[2][r]= sector.children[last_node_id].right;
           results[3][r]= sector.children[last_node_id].parent;
           results[4][r]= sector.children[last_node_id].data;
           r++;

           if(sector.children[last_node_id].right == 0x0){
             if(sector.right != 0x0){
               sector = index.children[sector.right];
               last_node_id = sector.root;
               continue;
             }
           break;
           }
           else {
             last_node_id = sector.children[last_node_id].right;}
          }

          return results;
    }

    function removeSection(bytes32 index_id,bytes32 section_id) idNotEmpty(section_id){
      assert(getParent(section_id) == index_id);
      TreeLib.Index storage index = indexes[index_id];
      delete(parent_child_lookup[section_id]);
      TreeLib.removeSection(index,section_id);
    }

    function removeNode(bytes32 index_id,bytes32 node_id) idNotEmpty(node_id){
      bytes32 section_id = getParent(node_id);
      assert(getParent(section_id) == index_id);
      TreeLib.Section storage sector = getSection(section_id);

      delete(parent_child_lookup[node_id]);
      TreeLib.removeNode(sector,node_id);

      if(sector.size == 0)
      removeSection(index_id,section_id);
    }

    function generateSection() returns (bytes32 section_id){
      uint i = 0;
      while(childExists(sha3(block.difficulty+i,block.number+i,block.timestamp+1))){
        i++;
      }
      return sha3(block.difficulty+i,block.number+i,block.timestamp+1);
    }

    function newIndex(bytes32 index_id)idNotEmpty(index_id){
        indexes[index_id] = TreeLib.newIndex(index_id,parent_max_size);
    }

    function insertSection(bytes32 parent_id) returns(bytes32){
        //Create new index, if it does not exist
        if(!indexExists(parent_id))
          newIndex(parent_id);

        bytes32 section_id = generateSection();

        //Parent is an Index, store as child of index
        TreeLib.Index storage index = indexes[parent_id];
        parent_child_lookup[section_id] =  parent_id;
        TreeLib.insertSection(index,section_id);
        return section_id;
    }

    function insertNode(bytes32 index_id, bytes32 node_id, bytes32 data){
        //Ensure index and node are not empty
        require(index_id!= 0x0 && node_id != 0x0);

        //Create new index, if it does not exist
        if(!indexExists(index_id))
          newIndex(index_id);

        //check to see the next available sector
        bytes32 section_id = nextSection(index_id);
        if(section_id == 0x0)
          section_id = insertSection(index_id);

        parent_child_lookup[node_id] =  section_id;
        TreeLib.insertNode(getSection(section_id),node_id,data);
    }

    function insertNodeBatch(bytes32 index_id, bytes32[2][5] data){
      require(index_id!= 0x0);

      //Create new index, if it does not exist
      if(!indexExists(index_id))
        newIndex(index_id);

      //check to see the next available sector
      bytes32 section_id = nextSection(index_id);
      if(section_id == 0x0)
        section_id = insertSection(index_id);
      uint to_fill = indexes[index_id].children[section_id].maxsize - indexes[index_id].children[section_id].size;

      for(uint d=0;d<data.length;d++){
        bytes32 node_id = data[d][0];
        bytes32 node_data = data[d][1];
        //Ensure index and node are not empty
        if(node_id == 0x0)
        continue;

        //Generate new sector if exceeded
        if(to_fill < d+1){
          section_id = nextSection(index_id);
          if(section_id == 0x0)
            section_id = insertSection(index_id);
          to_fill += indexes[index_id].children[section_id].maxsize - indexes[index_id].children[section_id].size;
        }

        bytes32 right = 0x0;
        bytes32 left = 0x0;
        if(d==0){
          TreeLib.Section storage sector = getSection(section_id);
          left = sector.last;
          sector.children[left].right = node_id;
        }
        else{
          left = data[d-1][0];
        }
        if(data.length>d+1)
          right = data[d+1][0];

        parent_child_lookup[node_id] =  section_id;
        TreeLib.insertNodeBatch(getSection(section_id),left,right,node_id,node_data);
      }
    }

    modifier idNotEmpty(bytes32 id){
        require(id != 0x0);
        _;
    }


}
