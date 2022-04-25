public class CybersourceAuthResponse {

	public Links x_links {get;set;} // in json: _links
	public ClientReferenceInformation clientReferenceInformation {get;set;} 
	public String id {get;set;} 
	public OrderInformation orderInformation {get;set;} 
	public PaymentAccountInformation paymentAccountInformation {get;set;} 
	public PaymentInformation paymentInformation {get;set;} 
	public PointOfSaleInformation pointOfSaleInformation {get;set;} 
	public ProcessorInformation processorInformation {get;set;} 
	public String reconciliationId {get;set;} 
	public String status {get;set;} 
	public String submitTimeUtc {get;set;} 

	public CybersourceAuthResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == '_links') {
						x_links = new Links(parser);
					} else if (text == 'clientReferenceInformation') {
						clientReferenceInformation = new ClientReferenceInformation(parser);
					} else if (text == 'id') {
						id = parser.getText();
					} else if (text == 'orderInformation') {
						orderInformation = new OrderInformation(parser);
					} else if (text == 'paymentAccountInformation') {
						paymentAccountInformation = new PaymentAccountInformation(parser);
					} else if (text == 'paymentInformation') {
						paymentInformation = new PaymentInformation(parser);
					} else if (text == 'pointOfSaleInformation') {
						pointOfSaleInformation = new PointOfSaleInformation(parser);
					} else if (text == 'processorInformation') {
						processorInformation = new ProcessorInformation(parser);
					} else if (text == 'reconciliationId') {
						reconciliationId = parser.getText();
					} else if (text == 'status') {
						status = parser.getText();
					} else if (text == 'submitTimeUtc') {
						submitTimeUtc = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'CybersourceAuthResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class AmountDetails {
		public String authorizedAmount {get;set;} 
		public String currency_Z {get;set;} // in json: currency

		public AmountDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'authorizedAmount') {
							authorizedAmount = parser.getText();
						} else if (text == 'currency') {
							currency_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AmountDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ClientReferenceInformation {
		public String code {get;set;} 

		public ClientReferenceInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ClientReferenceInformation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Card {
		public String type {get;set;} 

		public Card(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Card consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ProcessorInformation {
		public String approvalCode {get;set;} 
		public CardVerification cardVerification {get;set;} 
		public String networkTransactionId {get;set;} 
		public String transactionId {get;set;} 
		public String responseCode {get;set;} 
		public Avs avs {get;set;} 

		public ProcessorInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'approvalCode') {
							approvalCode = parser.getText();
						} else if (text == 'cardVerification') {
							cardVerification = new CardVerification(parser);
						} else if (text == 'networkTransactionId') {
							networkTransactionId = parser.getText();
						} else if (text == 'transactionId') {
							transactionId = parser.getText();
						} else if (text == 'responseCode') {
							responseCode = parser.getText();
						} else if (text == 'avs') {
							avs = new Avs(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ProcessorInformation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class OrderInformation {
		public AmountDetails amountDetails {get;set;} 

		public OrderInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'amountDetails') {
							amountDetails = new AmountDetails(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'OrderInformation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PaymentInformation {
		public Card tokenizedCard {get;set;} 
		public Card card {get;set;} 

		public PaymentInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'tokenizedCard') {
							tokenizedCard = new Card(parser);
						} else if (text == 'card') {
							card = new Card(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'PaymentInformation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CardVerification {
		public String resultCode {get;set;} 

		public CardVerification(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'resultCode') {
							resultCode = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CardVerification consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Links {
		public AuthReversal authReversal {get;set;} 
		public AuthReversal self {get;set;} 
		public AuthReversal capture {get;set;} 

		public Links(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'authReversal') {
							authReversal = new AuthReversal(parser);
						} else if (text == 'self') {
							self = new AuthReversal(parser);
						} else if (text == 'capture') {
							capture = new AuthReversal(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Links consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PointOfSaleInformation {
		public String terminalId {get;set;} 

		public PointOfSaleInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'terminalId') {
							terminalId = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PointOfSaleInformation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class AuthReversal {
		public String method {get;set;} 
		public String href {get;set;} 

		public AuthReversal(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'method') {
							method = parser.getText();
						} else if (text == 'href') {
							href = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AuthReversal consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PaymentAccountInformation {
		public Card card {get;set;} 

		public PaymentAccountInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'card') {
							card = new Card(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'PaymentAccountInformation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Avs {
		public String code {get;set;} 
		public String codeRaw {get;set;} 

		public Avs(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'codeRaw') {
							codeRaw = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Avs consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static CybersourceAuthResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CybersourceAuthResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	














}