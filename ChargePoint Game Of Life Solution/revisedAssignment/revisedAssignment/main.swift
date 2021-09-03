//
//  main.swift
//  revised assignment
//
//  Created by Nakul on 31/08/21.
//

import Foundation



// using struct as key in map
struct Key : Hashable{
    let row: Int
    let col: Int
}


// utility function
class Utility {
    static let SEPERATOR = " "
    static func makeKey(_ row: Int, _ col: Int) -> Key{
        return Key(row: row, col: col)
    }
    
}


class GameOfLife{
    // using dir row and dir column for reaching all the 8 adjacent neighbours of a cell
    private let dirRow = [ 0, -1, -1, -1, 0, 1, 1, 1]
    private let dirCol = [-1, -1,  0,  1, 1, 1, 0,-1]
    private let limiter = 100;
    
    //map for sparse matrix
    private var map = [Key: Int]()
    
    //coordinates of min max for both rows and columns
    private var rowMin = Int.max
    private var rowMax = Int.min
    private var colMin = Int.max
    private var colMax = Int.min

    // init for game of life class it accepts 2d array as a seed of life
    init(_ grid: [[Int]]) {
        for row in 0..<grid.count {
            for col in 0..<grid[0].count {
                if(grid[row][col] == 1){
                    map[Utility.makeKey(row, col)] = 1
                    takeMinMax(row, col)
                }
            }
        }
        
     
    }
    
    // main solution
    func solution() {
        var count = 1
        let limiter = 5
        while (count <= limiter) {
            print("GEN: ----> \(count)")
            if(map.count == 0) {
                print("No living cell is alive")
                return
            }
            initializeNeighbours()
            getNextGenGrid()
            printGrid()
            count += 1
        }
        
        print("OVER:")
    }
    
    
   /* initialize all the 8 neighbours for each coordinate present in sparse matrix
      and this function will also handle the case in which coordinates overlap
      since we only have 1's in our sparse matrix so we initialize 0's as their neighbours
   */
    func initializeNeighbours() {
        var neighboursToAdd = [Key]()
        for coordinate in map.keys {
            let pair = coordinate
            
            for i in 0..<dirRow.count {
                let tempRow = pair.row + dirRow[i]
                let tempCol = pair.col + dirCol[i]
                
                neighboursToAdd.append(Utility.makeKey(tempRow, tempCol))
            }
            
        }
        
        for coordinate in neighboursToAdd {
            if map[coordinate] == nil {
                map[coordinate] = 0
            }
        }
        
//        print("COUNT  \(map.count)")
    }
    
    
    // getting the next gen matrix from this function
    func getNextGenGrid() {
        var coordinatesToRemove = [Key]()
        var coordinatesToAdd = [Key]()
        
        for coordinate in map.keys {
//            print(coordinates)
            let pair = coordinate
         
            let livingCount = findLivingNeighbours(pair.row, pair.col)
//                print("\(coordinates) \(livingCount) ")
            makeNextCellDecison(coordinate, livingCount, &coordinatesToRemove, &coordinatesToAdd)
            
        }
        
        addNewCoordinates(coordinatesToAdd)
        removeRedundantCoordinates(coordinatesToRemove)

        for coordinate in map.keys {
//            print(coordinates)

            let pair = coordinate
            takeMinMax(pair.row, pair.col)
        }
    }
    
    
    // if the current cell fulfill all the rules mentioned in order to be alive then it will remain alive
    // or else it will be removed from the sparse matrix
    func makeNextCellDecison(_ coordinates:Key,_ livingCount:Int, _ coordinatesToRemove: inout[Key],_ coordinatesToAdd: inout[Key]) {
        if(livingCount < 2 || livingCount > 3) {
            coordinatesToRemove.append(coordinates)
        }
        else if(map[coordinates] == 0) {
            if livingCount == 3 {
                coordinatesToAdd.append(coordinates)
            }else {
                coordinatesToRemove.append(coordinates)
            }
        }
    }
    
    
    // it receives the list of coordinates which has to be remained and it replaces them with value 1
    // this function makes 0 -> 1 and makes 1 -> 1
    func addNewCoordinates(_ coordinatesToAdd: [Key]){
        for coordinates in coordinatesToAdd {
            map[coordinates] = 1
        }
    }
    
    
    // it receives the list of coordinates which has to be removed and it removes them
    func removeRedundantCoordinates(_ coordinatesToRemove:[Key]){
        for coordinates in coordinatesToRemove {
            map.removeValue(forKey: coordinates)
        }
    }
    
    
    // this function is used to find all the living neighbours of a single coordinate i.e neighbours having value 1
    func findLivingNeighbours(_ row:Int, _ col:Int) -> Int {
        var livingCount = 0
        
        for i in 0..<dirRow.count {
            let tempRow = row + dirRow[i]
            let tempCol = col + dirCol[i]
            
            if isNeighbourLiving(Utility.makeKey(tempRow, tempCol)) {
                livingCount += 1
            }
        }
        
        return livingCount
    }
    
    
    // a simple boolean function which checks for the neighbour coordinate having value 1 (living neighbour)
    func isNeighbourLiving(_ coordinates: Key) -> Bool{
        return map[coordinates] == 1
    }
    
    // function for increasing the grid bounds since the grid will be growing
    func takeMinMax(_ row: Int, _ col: Int){
        self.rowMin = min(row, self.rowMin)
        self.rowMax = max(row, self.rowMax)
        self.colMin = min(col, self.colMin)
        self.colMax = max(col, self.colMax)
    }
    
    
    func printGrid() {
        for row in rowMin...rowMax {
            for col in colMin...colMax {
                let coordinates = Utility.makeKey(row, col)
                if (map[coordinates] != nil) {
                    print(1, terminator: " ")
                }else {
                    print(0, terminator: " ")
                }
            }
            print()
        }
        print()
    }
    
}



//input for seed of life
let grid = [[0,1,0], [1,1,1], [0,1,0]]


let gol = GameOfLife(grid)

gol.solution()



/*
 Rules:
 The Game of Life Consists of a grid having cells of type living and dead
 since we have 2 states of a cell (i.e living or dead) we can represent this by 0 and 1
 0 represents dead cell
 1 represents living cell
 so the conditions were given as for each cell as follows:
 1 will become 0 if (it's living neighbours count is < 2 or > 3)
 1 will remain 1 if (it's living neighbours count is == 2 or == 3)
 0 will become 1 if (it's living neighbours count is == 3)
 
 Approach:
 As the grid grows there can be a lot of zeros so it can result in increased memory consumption so in order to tackle that situation i will be using a sparse matrix
 
 what sparse matrix does is it only contains the coordinates of living cells (i.e cells having value as 1)
 
 to implement such matrix i used a dictionary of type [Key: Int]
 
 where my key is : -
 
 struct Key : Hashable{
     let row: Int
     let col: Int
 }
 
 and the key would contain 0 or 1
 
 now the approach works as follows :-
 
 example : grid = [[1]]
 
 so we have a grid like this
idx | 0
-------
 0  | 1

 at first we put all the living cells coordinates into the dictionary
 and then i initialize all the 8 neighbours (if they dont exist) of all the living cells into the dictionary itself
 
 after initializing neighbours we have
 
 dictionary :-
 idx |-1  0  1
 --------------
 -1  | 0  0  0
  0  | 0  1  0
  1  | 0  0  0
 
 now we check all the coordinates of the dictionary and check whether the living
 conditions are being met or not
 
 now at
 row = -1 col = -1 ,  dict[row][col] = 0 , living neighbours = 1, it will be removed from dict
 
 row = -1 col = 0 ,  dict[row][col] = 0 , living neighbours = 1, it will be removed from dict
 
 row = -1 col = 2 ,  dict[row][col] = 0 , living neighbours = 1, it will be removed from dict
 
 as we go down further we fill find that no coordinates will be remaining alive
 
 and the resultant dict will act as the input for next generation
 
 thats how this approach works
 
 
 */
