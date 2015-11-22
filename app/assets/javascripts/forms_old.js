$(document).ready(function () {

    // set up and initialise data
    var formData = {};
    var currentNode = "1";
    var groupNodeId = 2;
    var itemNodeId = 1;
    
    // Make sure the initial group data set up
    formData[currentNode] = blankGroup();
    
    $('#main').DataTable({
        columnDefs: [ ]
    } );

    function clearField(id) {
    	element = document.getElementById(id);
        element.value = "";
    }
    
    function setText(id, value) {
    	element = document.getElementById(id);
        element.value = value;
    }
    
    function setBoolean(id, value) {
    	element = document.getElementById(id);
        element.checked = value;
    }

    function getText(id) {
    	element = document.getElementById(id);
        return element.value;
    }

    function getBoolean(id) {
    	element = document.getElementById(id);
        return element.checked;
    }

    function blankGroup() {
        var groupData = {};
        groupData["name"] = "";
        groupData["note"] = "";
        groupData["optional"] = false;
        groupData["repeating"] = false;
        return groupData;
    }
        
    // Prevent tab being clicked. Want it under control of the groups and items
    $('#tab a').click(function (e) {
        e.preventDefault()
        return false;
    })

    $(document).on("click", ".list-group-item", function () {
        if (currentNode != "") {
            element = document.getElementById(currentNode);
            if (currentNode.indexOf(".") == -1) {
                element.className = "list-group-item";
            } else {
                element.className = "list-group-item list-group-item-success";
            }
        }
        currentNode = this.id;
        if (currentNode.indexOf(".") == -1) {
            element = document.getElementById(currentNode);
            element.className = "list-group-item active";
            $('#tab a[href="#groupTab"]').tab('show');
            
            var groupData = formData[currentNode];
           	setText("groupName",groupData["name"]);
           	setText("groupNote",groupData["note"]);
           	setBoolean("groupOptional",groupData["optional"]);
           	setBoolean("groupRepeating",groupData["repeating"]);
            
        } else {
            element = document.getElementById(currentNode);
            element.className = "list-group-item active";
            $('#tab a[href="#itemTab"]').tab('show');
        }
        return false;
    });

    $("button").on("click", function () {
        //alert("Button. Id=" + this.id);
        if (this.id == "addGroupButton") {
            
            var parent = document.getElementById("formEditor");
            var child = document.createElement("li");
            child.setAttribute("id", groupNodeId);
            child.setAttribute("class", "list-group-item");
            child.appendChild(document.createTextNode("Group"));
            parent.appendChild(child);
            
           	// Set the data for the new group.
           	formData[groupNodeId] = blankGroup();
			
            groupNodeId += 1;
            
        } else if (this.id == "addItemButton") {
            if (currentNode != "") {
                //alert("Add child, id=" + this.id);			
                var id = currentNode
                if (id.indexOf(".") == -1) {
                    var parent = document.getElementById(currentNode);
                    var ulElement = parent.getElementsByTagName("ul")[0];
                    if (typeof ulElement == 'undefined') {
                        ulElement = document.createElement("ul");
                        ulElement.setAttribute("class", "list-group");
                        parent.appendChild(ulElement);
                    }
                    parent = ulElement;
                    var child = document.createElement("li");
                    child.setAttribute("id", id + "." + itemNodeId);
                    itemNodeId += 1;
                    child.setAttribute("class", "list-group-item list-group-item-success");
                    child.appendChild(document.createTextNode("Item"));
                    parent.appendChild(child);
                }
            }
        } else if (this.id == "deleteButton") {
            var child;
            var parent;
            if (currentNode != "") {
                //alert("Delete currentNode=" + currentNode);			
                if (currentNode.indexOf(".") == -1) {
                    child = document.getElementById(currentNode);
                    if (child.childNodes.length == 1) {
                        inner = child.childNodes[0];
                        if (inner.nodeType == 3) {
                            //alert("Delete group=" + child.id);			
                            parent = child.parentNode;
                            parent.removeChild(child);
                            //alert("Delete parent=" + parent.id);			
                            currentNode = "";
                        }
                    }
                } else {
                    child = document.getElementById(currentNode);
                    parent = child.parentNode;
                    parent.removeChild(child);
                    if (parent.childNodes.length == 0) {
                        child = parent;
                        parent = child.parentNode;
                        parent.removeChild(child);
                        //alert("Delete parent=" + parent.id);	
                        currentNode = "";
                    } else {
                        currentNode = "";
                    }
                }
            }
        } else if (this.id == "groupUpdateButton") {
        	if (currentNode != "") {
                
                // Save the data. Get the group entry and save.
                var groupData = formData[currentNode];
                var name = getText("groupName");
                groupData['name'] = name;
                groupData['note'] = getText("groupNote");
                groupData['optional'] = getBoolean("groupOptional");
                groupData['repeating'] = getBoolean("groupRepeating");
				formData[currentNode] = groupData;
                
                // Set the group name.
                var node = document.getElementById(currentNode);
                node.innerHTML = name;
            }
        }
        return false;
    });
});