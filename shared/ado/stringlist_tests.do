clear

discard
.li = .stringlist.new
.li.append "entry 1"
.li.append "second entry"


di "First entry is: `.li.get 1'"
di "Second entry is: `.li.get 2'"

.li.loop_reset
while (`.li.loop_next') {
	.li.loop_di
}

stringlist_ado_test .li
