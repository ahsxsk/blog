---
title: 如何进行高质量的代码审查-来自LinkedIn的实践提示
date: 2018-03-12 08:44:52
tags: 
categories: [技术文摘]
---

[LinkedIn 代码审查实践原文 LinkedIn’s Tips for Highly Effective Code Review
](https://thenewstack.io/linkedin-code-review/)
### 摘要
- LinkedIn将Code Review作为员工日常工作之一，并且是员工晋升的重要考核因素。借此，LinkedIn建立了健康的反馈文化：工程师在各个领域都对提出和接受反馈持开放态度。
- Do I Understand the “Why”?     
负责审查的同学必须提前了解到代码改动的原因，而不是从代码改动中推测原因。
- Am I Giving Positive Feedback?   
代码审查不仅要给出代码的问题，更要尽量给出代码写的优秀的地方，这样能给工程师带来鼓励，使其更有动力。
- Is My Code Review Comment Explained Well?   
提出的Review意见必须是能够使被review的同学清晰理解的。宁可花费大量文字去过度解释review意见，也绝不简单输入可能会造成别人理解困惑的意见。
- Do I Appreciate the Submitter’s Effort?    
我们需要充分肯定和尊重工程师所做的努力，即使代码有需要改进的地方。这有助于建立起一个强大的、具有很高积极性的团队。
- Would This Review Comment Be Useful to Me?    
确保我们提出的Review意见都是有用的，如果我们自己都觉得没用，那么只会给被审查人带来额外的负担。例如：代码格式问题，这个需要通过自动化工具来解决而不是通过review来解决。
- Is the “Testing Done” Section Thorough Enough?    
提交Review的代码必须经过充分的测试，这个充分的测试根据修改的复杂度而不同。
- Am I Too Pedantic in My Review?    
防止大量不重要的小修改意见淹没重要的review意见

