from memory import memset_zero
from random import rand, random_float64

alias type = DType.float32

struct Matrix[rows: Int, cols: Int]:
    var data: DTypePointer[type]

    # Initialize zeroeing all values
    fn __init__(inout self):
        self.data = DTypePointer[type].alloc(rows * cols)
        memset_zero(self.data, rows * cols)

    # Initialize taking a pointer, don't set any elements
    fn __init__(inout self, data: DTypePointer[type]):
        self.data = data

    # Initialize with random values
    @staticmethod
    fn rand() -> Self:
        var data = DTypePointer[type].alloc(rows * cols)
        rand(data, rows * cols)
        return Self(data)
        
    fn __getitem__(self, y: Int, x: Int) -> Scalar[type]:
        return self.load[1](y, x)

    fn __setitem__(self, y: Int, x: Int, val: Scalar[type]):
        self.store[1](y, x, val)

    fn load[nelts: Int](self, y: Int, x: Int) -> SIMD[type, nelts]:
        return self.data.load[width=nelts](y * self.cols + x)

    fn store[nelts: Int](self, y: Int, x: Int, val: SIMD[type, nelts]):
        return self.data.store[width=nelts](y * self.cols + x, val)

    fn inplace_transpose(self):
        # var swap: Float32 = 0.0
        # for x in rows:
        #     for y in cols:
        #         swap = self.load(y, x)
        #         self.store(y, x) = self.load(x, y)
        #         self.store(x, y) = swap
        var swap: Int = self.rows
        # self.rows = self.cols
        # self.cols = swap


    fn __str__(self) -> String:
        var matrix_string = String("")
        for r in range(rows):
            matrix_string += String(self.load[cols](r,0))
            matrix_string += "\n"
        return matrix_string

# Note that C, A, and B have types.
fn matmul_naive(C: Matrix, A: Matrix, B: Matrix):
    for m in range(C.rows):
        for k in range(A.cols):
            for n in range(C.cols):
                C[m, n] += A[m, k] * B[k, n]

# Parallelize the code by using the builtin parallelize function
alias nelts = simdwidthof[DType.float32]() * 2
from algorithm import vectorize, parallelize

fn matmul(C: Matrix, A: Matrix, B: Matrix):
    @parameter
    fn calc_row(m: Int):
        for k in range(A.cols):
            @parameter
            fn dot[nelts : Int](n : Int):
                C.store[nelts](m,n, C.load[nelts](m,n) + A[m,k] * B.load[nelts](k,n))
            vectorize[dot, nelts, size = C.cols]()
    parallelize[calc_row](C.rows, C.rows)

struct Cell[input_size: Int]:
    var weights: Matrix[input_size, 1]

    # Initialize with random weights
    fn __init__(inout self):
        self.weights = Matrix[input_size, 1].rand()

    fn forward(self, input: Matrix[1, input_size]) -> Float32:
        var result =  Matrix[1, 1]()
        matmul(result, input, self.weights)
        return result[0,0]


fn main():
    var inputs = Matrix[1, 3]()

    for i in range(3):
        inputs[0, i] = 1

    print(inputs)

    var cell = Cell[3]()

    print(cell.weights)

    var o1 = cell.forward(inputs)
    print(o1)