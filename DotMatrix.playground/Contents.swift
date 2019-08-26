import Foundation

extension Array {
    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        var result = Array<B?>(repeating: nil, count: count)
        let q = DispatchQueue(label: "sync queue")
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let element = self[idx]
            let transformed = transform(element)
            q.sync {
                result[idx] = transformed
            }
        }
        return result.map { $0! }
    }
}

func getRandomMatrix<T: Numeric>(n: Int, m: Int, randomGenerator: () -> T) -> [[T]] {
    return (0..<n).map {_ in
        (0..<m).map { _ in
            randomGenerator()
        }
    }
}

enum DotError : Error { case incompatibleShape, emptyMatrix }

func dot<T: Numeric>(a: [[T]], b: [[T]]) throws -> [[T]] {
    guard a.count > 0 && b.count > 0 && a[0].count > 0 && b[0].count > 0 else {
        throw DotError.emptyMatrix
    }
    
    let (an, am) = (a.count, a[0].count)
    let (bn, bm) = (b.count, b[0].count)
    
    guard am == bn else {
        throw DotError.incompatibleShape
    }
    
    return Array(0..<an).concurrentMap { row in
        Array(0..<bm).concurrentMap { col in
            var tot:T = 0
            for i in 0..<am {
                tot += a[row][i] * b[i][col]
            }
            return tot
//            (0..<am).reduce(0) { (t, i) in
//                t + a[row][i] * b[i][col]
//            }
        }
    }
}


//let a = [[1, 2, 3], [4, 5, 6]]
//let b = [[1, 2], [3, 4], [5, 6]]
let a = getRandomMatrix(n: 4, m: 4, randomGenerator: { Int.random(in: 0...9) })
let b = getRandomMatrix(n: 4, m: 4, randomGenerator: { Int.random(in: 0...9) })


let c = try? dot(a: a, b: b)

print(a)
print(b)
print(c!)

