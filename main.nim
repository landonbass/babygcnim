# port of http://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/

# nim has several gcs, and optionally none, so we will see where this learning project goes...

# max size of array, may switch to seq later
const STACK_MAX = 256

type
    # represents the type of the objects
    ObjectType = enum
        ObjInt
        ObjPair
     
    Node  = ref  NodeObject  
    
    # variant type representing each object
    NodeObject = object
        case kind: ObjectType
        of ObjInt  : intVal     : int 
        of ObjPair : head, tail : Node
    
    # defining the stack as an array 
    StackArray = array[STACK_MAX, NodeObject]   
    
    VM = ref VMObject
    
    # wrapping the stack and associated objects
    VMObject  = object
        Stack : StackArray
        StackSize : int

# this procedure pushes an object onto the stack
proc push (vm: VM, obj : NodeObject) :  void =
    let location : int = vm.StackSize + 1
    vm.Stack[location] = obj

# this procedure pops an object off of the stack   
proc pop (vm: VM) : NodeObject =
    result = vm.Stack[vm.StackSize]
    vm.StackSize = vm.StackSize - 1

# wrapper for creating a new VM    
proc newVm () : VM =
    var vm : VM
    result = vm

proc newObject (vm : VM, objType : ObjectType) : NodeObject =
    var node : NodeObject = NodeObject(kind: objType)
    return node

let vm : VM = newVm()

push(vm, NodeObject(kind: ObjInt))