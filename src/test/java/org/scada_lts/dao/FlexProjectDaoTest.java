/*
 * (c) 2016 Abil'I.T. http://abilit.eu/
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
package org.scada_lts.dao;

import br.org.scadabr.api.vo.FlexProject;
import org.junit.Test;
import org.springframework.dao.EmptyResultDataAccessException;

import java.util.List;

import static org.junit.Assert.assertTrue;

/**
 * Test FlexProjectDAO
 *
 * @author Mateusz Kaproń Abil'I.T. development team, sdt@abilit.eu
 */
public class FlexProjectDaoTest extends TestDAO {

	private static final String NAME = "flex name";
	private static final String DESCRIPTION = "flex description";
	private static final String XML_CONFIG = "flex xml config";

	private static final String SECOND_NAME = "second flex name";
	private static final String SECOND_DESCRIPTION = "second flex description";
	private static final String SECOND_XML_CONFIG = "second flex xml config";

	private static final int LIST_SIZE = 2;

	private static final String UPDATE_NAME = "update flex name";
	private static final String UPDATE_DESCRIPTION = "update flex description";
	private static final String UPDATE_XML_CONFIG = "update flex xml config";

	@Test
	public void test() {

		FlexProject flexProject = new FlexProject();
		flexProject.setName(NAME);
		flexProject.setDescription(DESCRIPTION);
		flexProject.setXmlConfig(XML_CONFIG);

		FlexProjectDAO flexProjectDAO = new FlexProjectDAO();

		//Insert objects
		int firstId = flexProjectDAO.insert(NAME, DESCRIPTION, XML_CONFIG);
		int secondId = flexProjectDAO.insert(SECOND_NAME, SECOND_DESCRIPTION, SECOND_XML_CONFIG);
		flexProject.setId(firstId);

		//Select single object
		FlexProject flexProjectSelect = flexProjectDAO.getFlexProject(firstId);
		Assert.assertTrue(flexProjectSelect.getId().equals(firstId));
		Assert.assertTrue(flexProjectSelect.getName().equals(NAME));
		Assert.assertTrue(flexProjectSelect.getDescription().equals(DESCRIPTION));
		Assert.assertTrue(flexProjectSelect.getXmlConfig().equals(XML_CONFIG));

		//Select all objects
		List<FlexProject> flexProjectList = flexProjectDAO.getFlexProjects();
		//Check list size
		Assert.assertTrue(flexProjectList.size() == LIST_SIZE);
		//Check IDs
		Assert.assertTrue(flexProjectList.get(0).getId().equals(firstId));
		Assert.assertTrue(flexProjectList.get(1).getId().equals(secondId));

		//Update
		flexProjectDAO.update(firstId, UPDATE_NAME, UPDATE_DESCRIPTION, UPDATE_XML_CONFIG);
		FlexProject flexProjectUpdate = flexProjectDAO.getFlexProject(firstId);
		Assert.assertTrue(flexProjectUpdate.getId().equals(firstId));
		Assert.assertTrue(flexProjectUpdate.getName().equals(UPDATE_NAME));
		Assert.assertTrue(flexProjectUpdate.getDescription().equals(UPDATE_DESCRIPTION));
		Assert.assertTrue(flexProjectUpdate.getXmlConfig().equals(UPDATE_XML_CONFIG));

		//Delete
		flexProjectDAO.delete(firstId);
		try{
			flexProjectDAO.getFlexProject(firstId);
		} catch(Exception e){
			Assert.assertTrue(e.getClass().equals(EmptyResultDataAccessException.class));
			Assert.assertTrue(e.getMessage().equals("Incorrect result size: expected 1, actual 0"));
		}
	}
}
