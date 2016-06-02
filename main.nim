# port of http://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/

const STACK_MAX = 256

type
    ObjectType = enum
        ObjInt
        ObjPair
     
    Node  = ref  NodeObject  
    
    NodeObject = object
        case kind: ObjectType
        of ObjInt  : intVal     : int 
        of ObjPair : head, tail : Node
     
    StackArray = array[STACK_MAX, NodeObject]   
    VM = object
        Stack : StackArray
        StackSize : int

proc push (vm: var VM, obj : NodeObject) :  void =
    let location : int = vm.StackSize + 1
    vm.Stack[location] = obj
    
proc pop (vm: var VM) : NodeObject =
    result = vm.Stack[vm.StackSize]
    vm.StackSize = vm.StackSize - 1
    
proc newVm () : VM =
    var vm : VM
    result = vm