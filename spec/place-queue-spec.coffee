PlaceQueue = require '../lib/place-queue'
{Point} = require 'atom'

describe 'PlaceQueue', ->
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

    it 'should ignore a second position if it is within threshold', ->
      place2 = filepath: 'a/b', position: {row:2, column:6}
      pq.push place2
      expect(pq.currentPlace()).toEqual(place1)

    it 'should accept a second position if it has a different filepath', ->
      place2 = filepath: 'a/b/c', position: {row:3, column:5}
      pq.push place2
      expect(pq.currentPlace()).toEqual(place2)
