PlaceQueue = require '../lib/place-queue'
{Point} = require 'atom'

describe 'PlaceQueue', ->
  describe 'areEqual', ->
    pq = null
    beforeEach ->
      pq = new PlaceQueue rowThreshold: 3, columnThreshold: 3

    it 'should find two things equal if they are within threshold', ->
      p1 = filepath: 'a/b', position: {row:8, column:5}
      p2 = filepath: 'a/b', position: {row:10, column:4}
      expect(pq.areEqual(p1, p2)).toBe(true)

    it 'should be false if the columns is above threshold', ->
      p1 = filepath: 'a/b', position: {row:8, column:8}
      p2 = filepath: 'a/b', position: {row:10, column:4}
      expect(pq.areEqual(p1, p2)).toBe(false)

    it 'should be false if the columns is above threshold', ->
      p1 = filepath: 'a/b', position: {row:5, column:5}
      p2 = filepath: 'a/b', position: {row:10, column:4}
      expect(pq.areEqual(p1, p2)).toBe(false)

    it 'should accept a second position if it has a different filepath', ->
      p1 = filepath: 'a/b', position: {row:5, column:5}
      p2 = filepath: 'a/b/c', position: {row:5, column:5}
      expect(pq.areEqual(p1, p2)).toBe(false)

  describe 'with one push', ->

    pq = null
    place = null
    beforeEach ->
      place = filepath: 'a/b', position: new Point(row:1, column:5)
      pq = new PlaceQueue()
      pq.push place

    it 'should give latest location', ->
      expect(pq.currentPlace()).toEqual(place)

    it 'should not change location after going down', ->
      pq.down()
      expect(pq.currentPlace()).toEqual(place)

    it 'should not change location after going up', ->
      pq.up()
      expect(pq.currentPlace()).toEqual(place)

    it 'should not change location after a complex series of ups and downs', ->
      pq.down()
      pq.down()
      pq.up()
      pq.up()
      pq.up()
      pq.down()
      pq.down()
      pq.down()
      expect(pq.currentPlace()).toEqual(place)

  describe 'with two pushes', ->

    pq = null
    place1 = null
    place2 = null
    beforeEach ->
      place1 = filepath: 'a/b', position: new Point(row:1, column:5)
      place2 = filepath: 'b/c', position: new Point(row:5, column:2)
      pq = new PlaceQueue()
      pq.push place1
      pq.push place2

    it 'should give latest location', ->
      expect(pq.currentPlace()).toEqual(place2)

    it 'should give place1 after going down', ->
      pq.down()
      expect(pq.currentPlace()).toEqual(place1)

    it 'should give place1 after going down twice', ->
      pq.down()
      pq.down()
      expect(pq.currentPlace()).toEqual(place1)

    it 'should give place2 after going down then up', ->
      pq.down()
      pq.up()
      expect(pq.currentPlace()).toEqual(place2)

    it 'should give place1 after going up then down', ->
      pq.up()
      pq.down()
      expect(pq.currentPlace()).toEqual(place1)

    it 'should not change location after going up', ->
      pq.up()
      expect(pq.currentPlace()).toEqual(place2)

  describe 'threshold', ->
    place1 = null
    pq = null
    beforeEach ->
      place1 = filepath: 'a/b', position: {row:3, column:5}
      pq = new PlaceQueue rowThreshold: 3, columnThreshold: 3
      pq.push place1

    it 'should accept a second position if its row is above threshold', ->
      place2 = filepath: 'a/b', position: {row:10, column:5}
      pq.push place2
      expect(pq.currentPlace()).toEqual(place2)

    it 'should accept a second position if its column is above threshold', ->
      place2 = filepath: 'a/b', position: {row:3, column:10}
      pq.push place2
      expect(pq.currentPlace()).toEqual(place2)

    it 'should ignore a second position if it is within threshold', ->
      place2 = filepath: 'a/b', position: {row:2, column:6}
      pq.push place2
      expect(pq.currentPlace()).toEqual(place1)

    it 'should accept a second position if it has a different filepath', ->
      place2 = filepath: 'a/b/c', position: {row:3, column:5}
      pq.push place2
      expect(pq.currentPlace()).toEqual(place2)

  fdescribe 'jumping', ->
    p1 = filepath: 'a/b', position: {row:1, column:1}
    p2 = filepath: 'a/b', position: {row:10, column:10}
    p3 = filepath: 'a/b', position: {row:20, column:20}
    pq = null

    beforeEach ->
      pq = new PlaceQueue rowThreshold: 3, columnThreshold: 3
      pq.push p1
      pq.push p2
      pq.push p3

    xit 'should discard new positions from the jump', ->
      # Simulate the fact that when you jump, rabbit will try to push the
      # change of location from the jump.  We want to ignore these.
      pq.down()
      pq.push p3
      pq.push p2
      expect(pq.positionStack.length).toBe(3)
      expect(pq.currentPlace()).toBe(p2)

    it 'should discard new positions from two jumps', ->
      # Simulate the fact that when you jump, rabbit will try to push the
      # change of location from the jump.  We want to ignore these.
      pq.down()
      pq.push p3
      pq.push p2
      pq.down()
      pq.push p2
      pq.push p1
      expect(pq.positionStack.length).toBe(3)
      expect(pq.currentPlace()).toBe(p1)

    it 'should discard new positions from down + up jumps', ->
      # Simulate the fact that when you jump, rabbit will try to push the
      # change of location from the jump.  We want to ignore these.
      pq.down()
      pq.push p3
      pq.push p2
      pq.up()
      pq.push p2
      pq.push p3
      expect(pq.positionStack.length).toBe(3)
      expect(pq.currentPlace()).toBe(p3)
