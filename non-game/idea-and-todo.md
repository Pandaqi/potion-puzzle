

## Future To-Do

Stretch Goals:

* @IDEA: Can we involve actual _color mixing_ somehow as the final difficulty?
* VISUALS: Split the ball and its blobby overlay -> so we can shift the overlay around like floating bubbles too.
* FEEDBACK:
  * Also give TEXT feedback on pressing that? Or display some arrow or "Target Potion" text permanently?
  * And give TEXT/IMAGE feedback on "This potion is FULL"? => Maybe some subtle sound effect when it happens + some animation that plays while a potion is full. => Or just display a subtle "lock" or something on it while full
* Reconsider the message the CORK sends 
  * => Only flash/show when you ATTEMPT to put something into a full potion?
  * => OR LIFT THE CORK when you hover over that potion to signal you CAN take something OUT of it!
    * write about this in the devlog!



## Difficulties

### Easiest

* num_potion_bounds = (2,3)
* potion_size_bounds = (2,3)
* potion_start_contents_bounds = (1,2)
* num_moves_bounds = (2,4)
* allow_different_potion_sizes = false

### Easy

* num_potion_bounds = (3,4)
* potion_size_bounds = (3,4)
* potion_start_contents_bounds = (1,3)
* num_moves_bounds = (3,5)
* allow_different_potion_sizes = false

### Medium

* num_potion_bounds = (4,6)
* potion_size_bounds = (3,6)
* potion_start_contents_bounds = (2,4)
* num_moves_bounds = (6,9)
* allow_different_potion_sizes = false

### Hard

* num_potion_bounds = (4,6)
* potion_size_bounds = (4,5)
* allow_different_potion_sizes = true
* potion_start_contents_bounds = (2,4)
* num_moves_bounds = (8,10)
* initial_state_diversity_factor = 0.5
* prefer_deep_grab_probability = 0.5

### Hardest

* num_potion_bounds = (6,8)
* potion_size_bounds = (4,6)
* allow_different_potion_sizes = true
* potion_start_contents_bounds = (2,5)
* num_moves_bounds = (10,14)
* initial_state_diversity_factor = 0.5
* prefer_deep_grab_probability = 0.5