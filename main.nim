# port of http://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/

# nim has several gcs, and optionally none, so we will see where this learning project goes...

# max size of array, may switch to seq later
const STACK_MAX    = 256

const GC_THRESHOLD = 10

type
    # represents the type of the objects
    ObjectType = enum
        ObjInt
        ObjPair
    
    Node  = ref  NodeObject  
    
    # variant type representing each object
    NodeObject = object
        marked : bool
        next   : Node
        case kind: ObjectType
        of ObjInt  : intVal     : int
        of ObjPair : head, tail : Node
    
    # defining the stack as an array 
    StackArray = array[STACK_MAX, Node]   
    
    VM = ref VMObject
    
    # wrapping the stack and associated objects
    VMObject  = object
        Stack     : StackArray
        StackSize : int
        FirstNode : Node 
        NumObjects, MaxObjects : int   

# this procedure pushes an object onto the stack
proc push (vm: VM, obj : Node) :  void =
    vm.Stack[vm.StackSize] = obj
    inc vm.StackSize
    
# this procedure pops an object off of the stack   
proc pop (vm: VM) : Node =
    dec vm.StackSize
    result = vm.Stack[vm.StackSize]

# wrapper for creating a new VM    
proc newVm () : VM =
    let vm : VM   = VM()
    vm.StackSize  = 0
    vm.FirstNode  = nil
    vm.NumObjects = 0
    vm.MaxObjects = GC_THRESHOLD
    result        = vm
    
proc mark(node: Node) : void =
    if node.marked: return
    
    node.marked = true
    
    if node.kind == ObjPair:
        mark node.head
        mark node.tail

proc markAll(vm: VM) : void =
    for i in 0..<vm.StackSize:
        mark vm.Stack[i]

proc sweep(vm: VM) : void =
    var node = vm.FirstNode
    while node != nil:
        if not node.marked:
            node = nil
            dec vm.NumObjects
        else:
            node = node.next       

proc gc(vm : VM) : void =
    echo "gc...."
    vm.markAll
    vm.sweep
    vm.MaxObjects = vm.NumObjects * 2

proc newObject (vm: VM, objType : ObjectType) : Node =
    if vm.NumObjects == vm.MaxObjects: gc vm
    
    var node : Node = Node(kind: objType)
    node.marked     = false
    node.next       = vm.FirstNode
    vm.FirstNode    = node
    inc vm.NumObjects
    
    return node

proc pushInt(vm: VM, val :int) : void =
    let obj = newObject(vm, ObjInt)
    obj.intVal = val
    push(vm, obj)

proc pushPair(vm: VM) : Node =
    result =  newObject(vm, ObjPair)
    result.tail = pop(vm)
    result.head = pop(vm)
    push(vm, result)

let vm : VM = newVm()

for i in 0..100:
    vm.pushInt(i)
discard vm.pushPair

