---@meta collision
---@class collision_lib

-- Define the collision module
collision = {}

allCollisions = {}
-- Table to keep track of previous collisions
previousCollisions = {}

function getDatarefs()
    acf_peX = get(globalPropertyf("sim/graphics/view/pilots_head_x"))
    acf_peZ = get(globalPropertyf("sim/graphics/view/pilots_head_z"))
    acf_peY = get(globalPropertyf("sim/graphics/view/pilots_head_y"))
    return acf_peX, acf_peY, acf_peZ
end

--- Initialize a new collision object with a set of points
---@param points table An array of points defining a polygon (e.g., rectangle or arbitrary shape)
---@return table collisionObject The collision object initialized with the given points
function collision.newCollisionObject(points)
    return {
        points = points,
        isColliding = false  -- Track if the object is currently colliding
    }
end

--- Checks if two polygons collide using Separating Axis Theorem (SAT)
---@param shapeA table The first shape defined by an array of points
---@param shapeB table The second shape defined by an array of points
---@return boolean isColliding True if the shapes collide, false otherwise
function collision.checkCollision(shapeA, shapeB)
    -- Implement SAT or other collision detection logic and return true if colliding
    return false  -- Replace this with actual collision logic
end

--- Detects if this frame is the start of a new collision
---@param shapeA table The first shape
---@param shapeB table The second shape
---@return boolean isEntering True if the collision has just started
function collision.enterCollision(shapeA, shapeB)
    local id = shapeA .. "-" .. shapeB
    if collision.checkCollision(shapeA, shapeB) and not previousCollisions[id] then
        previousCollisions[id] = true
        return true
    end
    return false
end

--- Detects if the shapes are currently touching (colliding continuously)
---@param shape_pos number Enter the number of the collision
---@return boolean isTouching True if the objects are still colliding
function collision.isTouching(shape_pos)
    if allCollisions[shape_pos] then
        d_x, d_y, d_z = getDatarefs()
        --print(d_x >= allCollisions[shape_pos].min[1], d_x <= allCollisions[shape_pos].max[1],
        --d_y >= allCollisions[shape_pos].min[2], d_y <= allCollisions[shape_pos].max[2],
        --d_z >= allCollisions[shape_pos].min[3], d_z <= allCollisions[shape_pos].max[3])
        --print(d_x, d_y, d_z)
        if d_x >= allCollisions[shape_pos].min[1] and d_x <= allCollisions[shape_pos].max[1] and
           d_y >= allCollisions[shape_pos].min[2] and d_y <= allCollisions[shape_pos].max[2] and
           d_z >= allCollisions[shape_pos].min[3] and d_z <= allCollisions[shape_pos].max[3] then
            return true
        end
        return false
    end
    return false
    --return collision.checkCollision(shapeA, shapeB)
end

--- Detects if the objects have just exited collision
---@param shapeA table The first shape
---@param shapeB table The second shape
---@return boolean isExiting True if the collision just ended
function collision.exitCollision(shapeA, shapeB)
    local id = shapeA .. "-" .. shapeB
    if not collision.checkCollision(shapeA, shapeB) and previousCollisions[id] then
        previousCollisions[id] = nil
        return true
    end
    return false
end

--- Deletes a specific collision state, stopping tracking between two objects
---@param shapeA table The first shape
---@param shapeB table The second shape
function collision.deleteCollision(shapeA, shapeB)
    local id = shapeA .. "-" .. shapeB
    previousCollisions[id] = nil
end

--- Clears all previous collision data (useful for resetting)
function collision.clearPreviousCollisions()
    previousCollisions = {}
end

--- Draws the collision shape on screen (for debugging or visualization)
---@param min_shape table A shape defined by an array of points
---@param max_shape table B shape defined by an array of points
function collision.drawCollision(min_shape, max_shape)

    table.insert(allCollisions, {min = min_shape, max = max_shape})
    -- Code to render or visualize the shape
end

return collision