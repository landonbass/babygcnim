# port of http://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/

# nim has several gcs, and optionally none, so we will see where this learning project goes...

# max size of array, may switch to seq later
const STACK_MAX = 256

type
    # represents the type of the objects
    ObjectType = enum
        ObjInt
        ObjPair
    
    IntVal = tuple[intVal: int, marked: bool]
     
    Node  = ref  NodeObject  
    
    # variant type representing each object
    NodeObject = object
        case kind: ObjectType
        of ObjInt  : intVal     : IntVal
        of ObjPair : head, tail : Node
    
    # defining the stack as an array 
    StackArray = array[STACK_MAX, Node]   
    
    VM = ref VMObject
    
    # wrapping the stack and associated objects
    VMObject  = object
        Stack : StackArray
        StackSize : int

# this procedure pushes an object onto the stack
proc push (vm: VM, obj : Node) :  void =
    let location : int = vm.StackSize + 1
    vm.Stack[location] = obj

# this procedure pops an object off of the stack   
proc pop (vm: VM) : Node =
    result = vm.Stack[vm.StackSize]
    vm.StackSize = vm.StackSize - 1

# wrapper for creating a new VM    
proc newVm () : VM =
    var vm : VM
    result = vm

#proc newObject (objType : ObjectType) : Node =
#    var node : Node = NodeObject(kind: objType)
#    return node

proc pushInt(vm: VM, val :int) : void =
    let obj = Node(kind: ObjInt, intVal: (intVal: val, marked: false))
    push(vm, obj)

proc pushPair(vm: VM) : Node =
    result =  Node(kind: ObjInt, head: pop(vm), tail: pop(vm))
    push(vm, result)

let vm : VM = newVm()

pushInt(vm, 5)
discard pushPair(vm)